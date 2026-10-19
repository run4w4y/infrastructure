#!/usr/bin/env python3
"""Prove private CI access with a scheduler dry run and live-state checks."""

import http.client
import json
import os
import socket
import ssl
import subprocess
import urllib.parse


def main():
    target = urllib.parse.urlsplit(os.environ['NOMAD_ADDR'])
    context = ssl.create_default_context(cafile=os.environ['NOMAD_CACERT'])
    control, host = os.environ['CLUSTER_NOMAD_CONTROL'], os.environ['CLUSTER_NOMAD_HOST']
    token = os.environ.pop('NOMAD_TOKEN')
    job = os.environ['CLUSTER_PROBE_JOB']
    if target.scheme != 'https' or target.hostname != '127.0.0.1':
        raise RuntimeError('The probe must use the private loopback SSH forward')

    class Nomad(http.client.HTTPSConnection):
        def connect(self):
            raw = socket.create_connection((target.hostname, target.port), timeout=10)
            self.sock = context.wrap_socket(raw, server_hostname='server.global.nomad')

    def request(path, body=None, authenticated=True):
        connection = Nomad('server.global.nomad', target.port, timeout=10)
        headers = {'Content-Type': 'application/json'}
        if authenticated:
            headers['X-Nomad-Token'] = token
        connection.request('POST' if body is not None else 'GET', path,
                           None if body is None else json.dumps(body).encode(), headers)
        response = connection.getresponse()
        content = response.read()
        status = response.status
        connection.close()
        return status, json.loads(content) if status == 200 and content else None

    with socket.create_connection((target.hostname, target.port), timeout=10) as raw:
        try:
            ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT).wrap_socket(raw, server_hostname='server.global.nomad')
        except ssl.SSLCertVerificationError:
            pass
        else:
            raise RuntimeError('An untrusted CA unexpectedly succeeded')
    with socket.create_connection((target.hostname, target.port), timeout=10) as raw:
        try:
            context.wrap_socket(raw, server_hostname='wrong-server.invalid')
        except ssl.SSLCertVerificationError:
            pass
        else:
            raise RuntimeError('An incorrect TLS hostname unexpectedly succeeded')
    if request('/v1/jobs', authenticated=False)[0] != 403:
        raise RuntimeError('Native Nomad ACL authentication was not enforced')
    status, actual = request('/v1/job/' + urllib.parse.quote(job, safe=''))
    if status != 200:
        raise RuntimeError('CI cannot read its existing job: HTTP ' + str(status))
    job_path = '/v1/job/' + urllib.parse.quote(job, safe='')

    def allocations():
        status, items = request(job_path + '/allocations')
        if status != 200:
            raise RuntimeError('CI cannot read its job allocations: HTTP ' + str(status))
        return {item['ID']: {
            'client_status': item['ClientStatus'],
            'desired_status': item['DesiredStatus'],
            'tasks': {name: {key: state.get(key) for key in
                            ['State', 'StartedAt', 'FinishedAt', 'Restarts', 'LastRestart']}
                      for name, state in (item.get('TaskStates') or {}).items()},
        } for item in items}

    before_allocations = allocations()
    status, plan = request('/v1/job/' + urllib.parse.quote(job, safe='') + '/plan',
                           {'Job': actual, 'Diff': True, 'PolicyOverride': False})
    if status != 200:
        raise RuntimeError('The scheduler dry run failed: HTTP ' + str(status))
    if plan.get('FailedTGAllocs'):
        raise RuntimeError('The scheduler dry run has failed placements')
    if plan.get('JobModifyIndex') != actual['JobModifyIndex']:
        raise RuntimeError('The dry run used a different live job revision')
    status, after = request(job_path)
    if status != 200 or any(after[key] != actual[key] for key in ['JobModifyIndex', 'Version']):
        raise RuntimeError('The live job changed during the dry run')
    if allocations() != before_allocations:
        raise RuntimeError('Live allocations or task lifetimes changed during the dry run')

    common = ['ssh', '-S', control, '-o', 'BatchMode=yes']
    execute = subprocess.run([*common, '-T', host, 'id'], capture_output=True, timeout=15)
    if execute.returncode == 0:
        raise RuntimeError('The forwarding account accepted a remote command')
    reverse = subprocess.run([*common, '-O', 'forward', '-R', '127.0.0.1:0:127.0.0.1:4646', host],
                             capture_output=True, timeout=15)
    if reverse.returncode == 0:
        raise RuntimeError('The forwarding account accepted a reverse forward')
    with socket.socket() as temporary:
        temporary.bind(('127.0.0.1', 0))
        denied_port = temporary.getsockname()[1]
    rule = f'127.0.0.1:{denied_port}:127.0.0.1:8200'
    subprocess.run([*common, '-O', 'forward', '-L', rule, host], check=True, capture_output=True)
    try:
        with socket.create_connection(('127.0.0.1', denied_port), timeout=5) as raw:
            try:
                context.wrap_socket(raw, server_hostname='vault.service.consul')
            except (ssl.SSLError, OSError):
                pass
            else:
                raise RuntimeError('The forwarding account reached Vault instead of only Nomad')
    finally:
        subprocess.run([*common, '-O', 'cancel', '-L', rule, host], check=True, capture_output=True)
    curl = subprocess.run(['curl', '--fail', '--silent', '--show-error',
                           os.environ['NOMAD_ADDR'] + '/v1/status/leader'], capture_output=True, timeout=15)
    if curl.returncode or not json.loads(curl.stdout):
        raise RuntimeError('The existing curl deployment client does not trust the private origin')
    print(json.dumps({'status': 'passed', 'job': job, 'plan_dry_run_completed': True,
                      'live_job_unchanged': True, 'allocation_task_lifetimes_unchanged': True,
                      'plan_diff_type': (plan.get('Diff') or {}).get('Type'),
                      'plan_desired_updates': (plan.get('Annotations') or {}).get('DesiredTGUpdates'),
                      'native_acl_required': True, 'tls_ca_and_hostname_verified': True,
                      'wrong_ca_rejected': True, 'wrong_hostname_rejected': True,
                      'remote_command_denied': True, 'reverse_forward_denied': True,
                      'vault_forward_denied': True, 'curl_client_verified': True}))


if __name__ == '__main__':
    main()

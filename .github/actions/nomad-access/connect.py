#!/usr/bin/env python3
"""Open the GitHub runner's forwarding-only SSH connection to Nomad."""

import json
import os
from pathlib import Path
import shutil
import ssl
import subprocess
import tempfile
import urllib.request


def connect():
    action = Path(__file__).resolve().parent
    repository = action.parents[2]
    ca = repository / 'pki/cluster-ca.pem'
    known = repository / 'pki/cluster-ssh-known-hosts'
    host = 'nomad-ci@' + known.read_text().split()[0]
    port = int(os.environ.get('CLUSTER_NOMAD_LOCAL_PORT', '14646'))
    if not 1024 <= port <= 65535:
        raise RuntimeError('The local forwarding port must be unprivileged')
    directory = Path(tempfile.mkdtemp(prefix='cluster-ci-', dir=os.environ['RUNNER_TEMP']))
    directory.chmod(0o700)
    key, control = directory / 'identity', directory / 'ssh.sock'
    key.write_text(os.environ.pop('NOMAD_CI_SSH_PRIVATE_KEY') + '\n')
    key.chmod(0o600)
    common = ['ssh', '-S', str(control), '-o', 'BatchMode=yes', '-o', 'IdentitiesOnly=yes',
              '-o', 'StrictHostKeyChecking=yes', '-o', 'UserKnownHostsFile=' + str(known),
              '-o', 'HostKeyAlgorithms=ssh-ed25519', '-o', 'ConnectTimeout=10']
    try:
        subprocess.run([*common, '-M', '-fNT', '-i', str(key), '-o', 'ExitOnForwardFailure=yes',
                        '-o', 'ServerAliveInterval=15', '-o', 'ServerAliveCountMax=3',
                        '-L', f'127.0.0.1:{port}:127.0.0.1:4646', host],
                       check=True, capture_output=True, timeout=30)
        context = ssl.create_default_context(cafile=str(ca))
        address = f'https://127.0.0.1:{port}'
        with urllib.request.urlopen(address + '/v1/status/leader',
                                    context=context, timeout=10) as response:
            if response.status != 200 or not json.load(response):
                raise RuntimeError('Nomad private leader health failed')
        bundle = directory / 'ca-bundle.pem'
        stock = ssl.get_default_verify_paths().cafile or '/etc/ssl/certs/ca-certificates.crt'
        bundle.write_bytes(Path(stock).read_bytes() + b'\n' + ca.read_bytes())
        exports = {'NOMAD_ADDR': address, 'NOMAD_CACERT': str(ca),
                   'NOMAD_TLS_SERVER_NAME': 'server.global.nomad', 'CURL_CA_BUNDLE': str(bundle),
                   'NOMAD_SKIP_VERIFY': 'false',
                   'CLUSTER_NOMAD_CONTROL': str(control), 'CLUSTER_NOMAD_HOST': host,
                   'CLUSTER_NOMAD_DIRECTORY': str(directory), 'CLUSTER_NOMAD_ACTION': str(action)}
        with open(os.environ['GITHUB_ENV'], 'a') as output:
            for name, value in exports.items():
                output.write(name + '=' + value + '\n')
        print('Private Nomad connection ready; pinned SSH host key and HTTPS CA verified')
    except Exception:
        subprocess.run([*common, '-O', 'exit', host], capture_output=True)
        shutil.rmtree(directory)
        raise
    finally:
        key.unlink(missing_ok=True)


if __name__ == '__main__':
    connect()

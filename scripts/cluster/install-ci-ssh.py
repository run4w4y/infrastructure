#!/usr/bin/env python3
"""Install a forwarding-only CI account; accept public keys as JSON on stdin."""

import datetime
import hashlib
import json
import os
from pathlib import Path
import pwd
import shutil
import subprocess
import sys

BLOCK = '''# BEGIN managed Nomad CI forwarding
Match User nomad-ci
    AuthenticationMethods publickey
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    AllowTcpForwarding local
    PermitOpen 127.0.0.1:4646
    PermitListen none
    AllowStreamLocalForwarding no
    AllowAgentForwarding no
    X11Forwarding no
    PermitTTY no
    PermitTunnel no
    PermitUserRC no
    GatewayPorts no
    MaxSessions 0
    ForceCommand /usr/sbin/nologin
# END managed Nomad CI forwarding
'''


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout


def effective(path, user):
    return run('/usr/sbin/sshd', '-T', '-f', str(path), '-C',
               f'user={user},host=github-runner,addr=203.0.113.5')


def main():
    os.umask(0o077)
    data = json.load(sys.stdin)
    keys = data['public_keys']
    if set(keys) != {'infrastructure', 'cv'} or any(
        not value.startswith('ssh-ed25519 ') or '\n' in value for value in keys.values()
    ):
        raise RuntimeError('Exactly two single-line Ed25519 public keys are required')
    if len({' '.join(value.split()[:2]) for value in keys.values()}) != 2:
        raise RuntimeError('Each repository must have a distinct SSH key')
    config = Path('/etc/ssh/sshd_config')
    original = config.read_text()
    start = '# BEGIN managed Nomad CI forwarding'
    end = '# END managed Nomad CI forwarding'
    if start in original:
        if original.count(start) != 1 or original.count(end) != 1 or not original.rstrip().endswith(end):
            raise RuntimeError('The managed CI Match block must occur once at the end of sshd_config')
        prefix = original.split(start)[0]
    else:
        if end in original:
            raise RuntimeError('Incomplete managed CI Match block')
        prefix = original
    candidate = prefix.rstrip() + '\n\n' + BLOCK
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    backup = Path('/var/backups/cluster-access') / ('ci-ssh-' + stamp)
    backup.mkdir(mode=0o700)
    for name, public in keys.items():
        key_file = backup / (name + '.pub')
        key_file.write_text(public + '\n')
        run('ssh-keygen', '-l', '-f', str(key_file))
    shutil.copy2(config, backup / 'sshd_config')
    staged = backup / 'candidate'
    staged.write_text(candidate)
    run('/usr/sbin/sshd', '-t', '-f', str(staged))
    before_root, after_root = effective(config, 'root'), effective(staged, 'root')
    if before_root != after_root:
        raise RuntimeError('The candidate changes root SSH settings')
    ci = dict(line.split(' ', 1) for line in effective(staged, 'nomad-ci').splitlines())
    required = {'authenticationmethods': 'publickey', 'passwordauthentication': 'no',
                'kbdinteractiveauthentication': 'no', 'allowtcpforwarding': 'local',
                'permitopen': '127.0.0.1:4646', 'permitlisten': 'none',
                'allowstreamlocalforwarding': 'no', 'allowagentforwarding': 'no',
                'x11forwarding': 'no', 'permittty': 'no', 'permittunnel': 'no',
                'permituserrc': 'no', 'gatewayports': 'no', 'maxsessions': '0',
                'forcecommand': '/usr/sbin/nologin'}
    if any(ci.get(key) != value for key, value in required.items()):
        raise RuntimeError('The effective CI restrictions differ from the candidate')
    if data.get('prepare_only'):
        print(json.dumps({'status': 'validated_without_activation', 'backup': str(backup),
                          'root_effective_settings_unchanged': True,
                          'ci_effective_restrictions': required}))
        return
    home = Path('/var/lib/nomad-ci')
    marker = home / '.cluster-ci-managed'
    managed = marker.exists() and marker.stat().st_uid == 0 and marker.read_text() == 'cluster-nomad-ci-v1\n'
    try:
        account = pwd.getpwnam('nomad-ci')
        if not managed:
            raise RuntimeError('An unmanaged CI account already exists')
    except KeyError:
        if home.exists() and not managed:
            raise RuntimeError('An unmanaged CI home already exists')
        run('useradd', '--system', '--user-group', '--home-dir', '/var/lib/nomad-ci',
            '--shell', '/bin/sh', 'nomad-ci')
        account = pwd.getpwnam('nomad-ci')
    if account.pw_uid == 0 or account.pw_gid == 0 or account.pw_dir != '/var/lib/nomad-ci':
        raise RuntimeError('Unexpected existing CI account')
    if run('id', '-G', 'nomad-ci').split() != [str(account.pw_gid)]:
        raise RuntimeError('The CI account must have only its dedicated group')
    run('usermod', '--lock', 'nomad-ci')
    home.mkdir(exist_ok=True, mode=0o755)
    os.chown(home, 0, 0)
    home.chmod(0o755)
    marker.write_text('cluster-nomad-ci-v1\n')
    marker.chmod(0o600)
    os.chown(marker, 0, 0)
    directory = home / '.ssh'
    directory.mkdir(exist_ok=True, mode=0o750)
    os.chown(directory, 0, account.pw_gid)
    directory.chmod(0o750)
    authorized = directory / 'authorized_keys'
    if authorized.exists():
        shutil.copy2(authorized, backup / 'authorized_keys')
    restrictions = 'restrict,port-forwarding,permitopen="127.0.0.1:4646",command="/usr/sbin/nologin" '
    authorized.write_text(''.join(restrictions + value + '\n' for value in keys.values()))
    os.chown(authorized, 0, 0)
    authorized.chmod(0o644)
    rollback = backup / 'rollback.sh'
    restore_keys = (f'cp -p {backup}/authorized_keys {authorized}\n' if (backup / 'authorized_keys').exists()
                    else f'rm -f {authorized}\n')
    rollback.write_text('#!/bin/sh\nset -eu\n' + restore_keys +
                        f'cp -p {backup}/sshd_config /etc/ssh/sshd_config\n'
                        '/usr/sbin/sshd -t\nsystemctl reload ssh\n')
    rollback.chmod(0o700)
    unit = 'cluster-ci-ssh-rollback-' + stamp.lower()
    run('systemd-run', '--unit=' + unit, '--on-active=300s', str(rollback))
    temporary = config.with_name('.sshd_config.cluster-ci')
    temporary.write_text(candidate)
    temporary.chmod(0o644)
    os.replace(temporary, config)
    try:
        run('/usr/sbin/sshd', '-t')
        run('systemctl', 'reload', 'ssh')
    except Exception:
        run(str(rollback))
        raise
    report = {'status': 'installed_pending_connection_checks', 'rollback_unit': unit,
              'backup': str(backup), 'root_effective_settings_unchanged': True,
              'ci_effective_restrictions': required, 'ci_account_uid': account.pw_uid,
              'authorized_keys_root_owned': True, 'repository_keys': sorted(keys),
              'sshd_config_sha256': hashlib.sha256(config.read_bytes()).hexdigest()}
    (backup / 'installation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()

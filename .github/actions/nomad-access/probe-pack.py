#!/usr/bin/env python3
"""Exercise the deployment CLI's TLS client without registering a job."""

import json
import os
from pathlib import Path
import ssl
import subprocess
import tempfile
import urllib.error
import urllib.request


def main():
    name = 'cluster-ci-transport-probe'
    context = ssl.create_default_context(cafile=os.environ['NOMAD_CACERT'])

    def absent():
        request = urllib.request.Request(os.environ['NOMAD_ADDR'] + '/v1/job/' + name,
                                         headers={'X-Nomad-Token': os.environ['NOMAD_TOKEN']})
        try:
            urllib.request.urlopen(request, context=context, timeout=10).close()
        except urllib.error.HTTPError as error:
            if error.code == 404:
                return
            raise
        raise RuntimeError('The dry-run probe job unexpectedly exists')

    absent()
    with tempfile.TemporaryDirectory(prefix='cluster-pack-probe-', dir=os.environ['RUNNER_TEMP']) as directory:
        pack = Path(directory)
        (pack / 'metadata.hcl').write_text('''app {
  url = "https://github.com/run4w4y/infrastructure"
}
pack {
  name = "cluster-ci-transport-probe"
  description = "Plan only; never run"
  version = "0.0.1"
}
''')
        (pack / 'variables.hcl').write_text('')
        (pack / 'templates').mkdir()
        (pack / 'templates/probe.nomad.tpl').write_text('''job "cluster-ci-transport-probe" {
  type = "batch"
  datacenters = ["dc1"]
  group "probe" {
    count = 0
    task "probe" {
      driver = "docker"
      config {
        image = "busybox:1.37.0"
        command = "true"
      }
      resources {
        cpu = 20
        memory = 32
      }
    }
  }
}
''')
        result = subprocess.run(['nomad-pack', 'plan', str(pack), '--parser-v1', '--diff=false'],
                                capture_output=True, text=True, timeout=60)
        if result.returncode not in (0, 1) or 'Plan succeeded' not in result.stdout:
            raise RuntimeError('The deployment CLI dry run failed: ' + result.stdout[-1500:] + result.stderr[-1500:])
    absent()
    print(json.dumps({'nomad_pack_private_tls_plan_passed': True,
                      'probe_job_never_registered': True, 'plan_exit_code': result.returncode}))


if __name__ == '__main__':
    main()

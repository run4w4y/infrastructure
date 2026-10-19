#!/usr/bin/env python3
"""Close the runner's SSH master and remove its temporary public trust bundle."""

import os
from pathlib import Path
import shutil
import subprocess


def close():
    if not os.environ.get('CLUSTER_NOMAD_CONTROL'):
        return
    control, host = os.environ['CLUSTER_NOMAD_CONTROL'], os.environ['CLUSTER_NOMAD_HOST']
    command = ['ssh', '-S', control, '-o', 'BatchMode=yes']
    alive = subprocess.run([*command, '-O', 'check', host], capture_output=True)
    if alive.returncode == 0:
        subprocess.run([*command, '-O', 'exit', host], check=True, capture_output=True)
    directory = Path(os.environ['CLUSTER_NOMAD_DIRECTORY']).resolve()
    if directory.parent != Path(os.environ['RUNNER_TEMP']).resolve() or not directory.name.startswith('cluster-ci-'):
        raise RuntimeError('Unexpected runner temporary directory')
    shutil.rmtree(directory, ignore_errors=True)


if __name__ == '__main__':
    close()

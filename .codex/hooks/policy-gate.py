#!/usr/bin/env python3
import subprocess
import sys

commands = [
    ["bash", "scripts/ai/risk-check.sh"],
    ["bash", "scripts/ai/secret-scan.sh"],
]

for cmd in commands:
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(result.returncode)

#!/bin/zsh
set -euo pipefail

source_file="$PWD/Sources/MarstekMacWidget/main.swift"

grep -Eq '"start_time": "00:00"' "$source_file"
grep -Eq '"end_time": "23:59"' "$source_file"
grep -Eq '"power": power' "$source_file"
grep -Eq '"time_num": 9' "$source_file"
grep -Eq '"enable": 0' "$source_file"

echo "Manual payload regression checks passed"

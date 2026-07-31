#!/bin/zsh
set -euo pipefail

source_file="$PWD/Sources/MarstekMacWidget/main.swift"

rg -q '"start_time": "00:00"' "$source_file"
rg -q '"end_time": "23:59"' "$source_file"
rg -q '"power": power' "$source_file"
rg -q '"time_num": 9' "$source_file"
rg -q '"enable": 0' "$source_file"

echo "Manual payload regression checks passed"

#!/bin/zsh
set -euo pipefail

source_file="$PWD/Sources/MarstekMacWidget/main.swift"

grep -Fq '(-2500...2500).contains($0)' "$source_file"
grep -Fq 'guard (30...88).contains(value)' "$source_file"
grep -Fq 'let dodWasEdited = dodText != initialDODText' "$source_file"
grep -Fq 'self.client.setDOD(requestedDOD)' "$source_file"
grep -Fq 'method == "ES.SetMode" || method == "DOD.SET"' "$source_file"
grep -Fq 'SO_NOSIGPIPE' "$source_file"

active_payload=$(grep -F 'else if mode == "Manual" { config["manual_cfg"]' "$source_file")
for field in \
    '"time_num": 0' \
    '"start_time": "00:00"' \
    '"end_time": "23:59"' \
    '"week_set": 127' \
    '"power": power' \
    '"enable": 1'
do
    [[ "$active_payload" == *"$field"* ]]
done

placeholder_payload=$(sed -n '/let manualPlaceholderParams:/,/"enable": 0/p' "$source_file")
for field in \
    '"mode": "Manual"' \
    '"time_num": 9' \
    '"start_time": "00:00"' \
    '"end_time": "00:00"' \
    '"week_set": 0' \
    '"power": 0' \
    '"enable": 0'
do
    [[ "$placeholder_payload" == *"$field"* ]]
done

echo "Manual range and payload regression checks passed"

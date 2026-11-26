#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(realpath -e -- "${BASH_SOURCE[0]}")")/.."

expect_error() {
  local code=$1 message=$2 output status=0
  shift 2
  output=$("$@" 2>&1) || status=$?
  if [[ $status != "$code" || $output != *"$message"* ]]; then
    printf 'Esperava erro %s contendo "%s", mas obtive %s\n%s\n' "$code" "$message" "$status" "$output" >&2
    exit 1
  fi
}

# Todos os casos terminam na validação, sem chamar o Disko.
expect_error 2 'forneça explicitamente' scripts/prepare-disk.sh
expect_error 2 'forneça explicitamente' scripts/prepare-disk.sh --preview
expect_error 2 'forneça explicitamente' scripts/prepare-disk.sh --yes-wipe-all-disks
expect_error 1 'identificador de disco inteiro' scripts/prepare-disk.sh --preview /dev/sda
expect_error 1 'identificador de disco inteiro' scripts/prepare-disk.sh --preview /dev/disk/by-id/exemplo-part1
expect_error 1 'Informe explicitamente o disco' nix-instantiate --eval --strict -E '(import ./disk-config.nix {})'
expect_error 1 'existente, de disco inteiro' nix-instantiate --eval --strict \
  -E '(import ./disk-config.nix { disk = "/dev/disk/by-id/exemplo-part1"; })'
expect_error 1 'terminal interativo' bash -c \
  'source scripts/disk-safety.sh; confirm_disk /dev/disk/by-id/exemplo' </dev/null

printf 'Validações não destrutivas passaram.\n'

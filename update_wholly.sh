#!/usr/bin/env bash
set -Eeuo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' 'Wholly Crypto signed updater' 'Usage: update_wholly.sh [--check] [--yes]' \
    'Uses the installed release-verification key. Wallets and configuration are preserved.'
  exit 0
fi
(( EUID == 0 )) || { printf 'Run this updater as root.\n' >&2; exit 1; }
if [[ ! -f /root/whollycrypto/scripts/whollycrypto-cli.py || ! -f /root/whollycrypto/config/release-signing.pub ]]; then
  printf 'The release CLI is not installed. Use setup_wholly.sh on a fresh VPS; do not overwrite an existing merchant installation.\n' >&2
  exit 1
fi
exec /usr/bin/python3 -I /root/whollycrypto/scripts/whollycrypto-cli.py update "$@"

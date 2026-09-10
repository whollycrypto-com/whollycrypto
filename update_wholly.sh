#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' 'Wholly Crypto signed updater' 'Usage: update_wholly.sh [--check] [--yes]' \
    'Verifies the current updater with your installed release-verification key.' \
    'Wallets, configuration, credit checks and release verification are preserved.'
  exit 0
fi
(( EUID == 0 )) || { printf 'Run this updater as root.\n' >&2; exit 1; }
if [[ ! -f /root/whollycrypto/scripts/whollycrypto-cli.py || ! -f /root/whollycrypto/config/release-signing.pub ]]; then
  printf 'The release CLI is not installed. Use setup_wholly.sh on a fresh VPS; do not overwrite an existing merchant installation.\n' >&2
  exit 1
fi
# Keep stdin attached to the terminal for the normal update confirmation.
# The installed client verifies the new helper before any downloaded code runs.
exec /usr/bin/python3 -I -c '
# BEGIN VERIFIED UPDATE LAUNCHER
import importlib.util
from pathlib import Path
import sys
import tempfile

sys.dont_write_bytecode = True
ERROR_CLIENT = None

def load_client(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def verified_update(arguments):
    global ERROR_CLIENT
    installed = load_client(Path("/root/whollycrypto/scripts/whollycrypto-cli.py"), "installed_update_client")
    ERROR_CLIENT = installed
    args = installed.parser().parse_args(["update", *arguments])
    with installed.operation_lock():
        if args.check:
            installed.update(args)
            return
        installed.check_platform()
        installed.safe_directory(installed.ROOT)
        installed.regular(installed.KEY)
        if installed.PENDING.exists():
            installed.fail("An interrupted update needs attention. Run whollycrypto recover before updating again.")
        with tempfile.TemporaryDirectory(prefix=".verified-updater.", dir=installed.ROOT) as temporary:
            manifest, _ = installed.fetch_manifest(installed.KEY, temporary)
            watermark = installed.ROOT / "config/release-sequence.json"
            if watermark.exists() and manifest["sequence"] < installed.read_json(watermark)["sequence"]:
                installed.fail("Release replay protection rejected an older channel manifest.")
            current = installed.current_version()
            comparison = installed.version_tuple(manifest["version"]) > installed.version_tuple(current)
            if not comparison:
                if manifest["version"] != current:
                    installed.fail("The release channel is older than this installation. Downgrades are not automatic.")
                installed.say("Wholly Crypto " + current + " is up to date (stable).")
                return
            installer = manifest["installer"]
            helper = Path(temporary) / "installer.py"
            installed.say("Downloading the signed updater using the installed verification key...")
            installed.download(installer["path"], helper, 1024 * 1024,
                               expected_size=installer["size"], digest=installer["sha256"])
            candidate = load_client(helper, "verified_update_client")
            ERROR_CLIENT = candidate
            args.expected_target = {key: manifest[key] for key in ("version", "sequence")}
            candidate.update(args)

if __name__ == "__main__":
    try:
        verified_update(sys.argv[1:])
    except KeyboardInterrupt:
        print("\nInterrupted. Run whollycrypto recover only if an update journal remains.", file=sys.stderr)
        sys.exit(130)
    except Exception as error:
        message = ERROR_CLIENT.error_message(error) if ERROR_CLIENT else "Could not load the installed updater. No credentials were printed."
        print("\n[ERROR] Wholly Crypto: " + message, file=sys.stderr)
        sys.exit(1)
# END VERIFIED UPDATE LAUNCHER
' "$@"

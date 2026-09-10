#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' 'Wholly Crypto fresh-VPS setup — Linux x86-64, systemd, root' \
    'Ubuntu 22.04+, Debian 12+, Fedora 42+, Rocky/Alma/RHEL/Oracle/CentOS Stream 9–10,' \
    'openSUSE Leap 16/Tumbleweed, Arch Linux (also Mint 21+, Pop!_OS 22+, Manjaro and EndeavourOS).' \
    'Requires Python 3.9+, systemd 247+, 2 GB RAM and 3 GB free disk plus data/backups.' \
    'ARM64, Alpine/OpenRC and obsolete OS releases are not supported by this release.' \
    'Usage: setup_wholly.sh [--domain example.com --email you@example.com] [--yes] [--resume]' \
    '       setup_wholly.sh --check (compatibility and package plan only; no installation)' \
    'Options: --merchant-subdomain panel --pay-subdomain checkout --api-subdomain gateway' \
    '         --additional-domain example.net --currency EUR --basic-user admin' \
    '         --basic-password-file /root/private-password.txt (optional; never pass passwords as arguments)' \
    'Interactive setup asks for your choices; merchant.*, pay.* and api.* are defaults.' \
    'Point every hostname directly to this VPS. Open TCP 80/443 in server and provider firewalls, and keep SSH allowed.' \
    'Existing installations: whollycrypto update'
  exit 0
fi
(( EUID == 0 )) || { printf 'Run this installer as root.\n' >&2; exit 1; }
printf '%s\n' '' '########################################################' \
  '###              Wholly Crypto Setup                ###' \
  '########################################################' \
  'Self-hosted payments. Your server. Your keys.' \
  'Checking prerequisites and downloading a signed installer…'
source /etc/os-release
bootstrap_profile() {
  local distro="$1" version="$2" major
  major="${version%%.*}"
  [[ "$major" =~ ^[0-9]+$ ]] || major=0
  case "$distro" in
    ubuntu|pop) (( major >= 22 )) && printf apt ;;
    debian) (( major >= 12 )) && printf apt ;;
    linuxmint) (( major >= 21 )) && printf apt ;;
    fedora) (( major >= 42 )) && printf dnf ;;
    rhel|rocky|almalinux|ol|centos) (( major == 9 || major == 10 )) && printf dnf ;;
    opensuse-leap) (( major >= 16 )) && printf zypper ;;
    opensuse-tumbleweed) printf zypper ;;
    arch|manjaro|endeavouros) printf pacman ;;
    *) return 1 ;;
  esac
}
if [[ "$(uname -m)" != x86_64 || ! -d /run/systemd/system ]] || ! bootstrap_family="$(bootstrap_profile "${ID:-}" "${VERSION_ID:-}")"; then
  printf 'Unsupported platform. Run --help for supported Linux/systemd x86-64 distributions. No changes made.\n' >&2
  exit 1
fi
bootstrap_check=false
for option in "$@"; do [[ "$option" != --check ]] || bootstrap_check=true; done
bootstrap_ca=false
for bundle in /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/ca-bundle.pem; do
  [[ ! -s "$bundle" ]] || bootstrap_ca=true
done
if ! command -v python3 >/dev/null || ! command -v openssl >/dev/null || ! command -v ip >/dev/null || [[ "$bootstrap_ca" != true ]]; then
  if [[ "$bootstrap_check" == true ]]; then
    printf 'Linux family: %s. Install python3, openssl, ca-certificates and iproute/iproute2 to run the signed compatibility check. No packages were installed.\n' "$bootstrap_family" >&2
    exit 1
  fi
  printf '[SETUP] Installing bootstrap prerequisites with %s…\n' "$bootstrap_family"
  case "$bootstrap_family" in
    apt)
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y --no-install-recommends python3 openssl ca-certificates iproute2 ;;
    dnf) dnf -y install python3 openssl ca-certificates iproute ;;
    zypper)
      zypper --non-interactive refresh
      zypper --non-interactive install --no-recommends python3 openssl ca-certificates iproute2 ;;
    pacman) pacman -Syu --noconfirm --needed python openssl ca-certificates iproute2 ;;
  esac
fi
python3 -I -c 'import sys; sys.exit(0 if sys.version_info >= (3,9) else "Python 3.9+ is required; upgrade to a supported Linux version.")'
bootstrap_dir="$(mktemp -d /tmp/whollycrypto-bootstrap.XXXXXXXXXX)"
cleanup() {
  if [[ "$bootstrap_dir" =~ ^/tmp/whollycrypto-bootstrap\.[A-Za-z0-9]{10}$ && -d "$bootstrap_dir" && ! -L "$bootstrap_dir" ]]; then
    rm -rf --one-file-system -- "$bootstrap_dir"
  fi
}
trap cleanup EXIT
trap 'printf "\n[ERROR] Setup stopped. Review the message above; no credentials are printed.\n" >&2' ERR
python3 -I - "$bootstrap_dir" <<'PY'
import base64, hashlib, http.client, json, os, pathlib, re, shutil, subprocess, sys, tempfile, threading, time, urllib.error, urllib.parse, urllib.request
from pathlib import Path
root = pathlib.Path(sys.argv[1])
ORIGIN = 'https://releases.whollycrypto.com'
public_key = '''-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE4auzTJIzB9zdTLnZWvybWjybEbN5
juKNiAsuu0Y4C3rb9TcXeBmzQ8fHnqEaq+5HmoINtc41SQxbUDtFndQqnw==
-----END PUBLIC KEY-----
'''

class Failure(Exception):
    pass

def fail(message):
    raise Failure(message)

def say(message):
    progress_message(message)

# Also embedded in the public bootstrap. Labels are fixed text/validated hosts,
# never subprocess arguments, output, environment values or credentials.
_PROGRESS_LOCK = threading.RLock()
_ACTIVE_PROGRESS = None
LAST_FAILED_OPERATION = ''


def progress_message(message):
    with _PROGRESS_LOCK:
        if _ACTIVE_PROGRESS is not None:
            _ACTIVE_PROGRESS.clear()
        print(message, flush=True)
        if _ACTIVE_PROGRESS is not None and _ACTIVE_PROGRESS.animated:
            _ACTIVE_PROGRESS.render()


class Progress:
    heartbeat_seconds = 15

    def __init__(self, label, *, total=None, enabled=None):
        self.label = ''.join(c for c in label if c.isprintable())[:300]
        self.total, self.completed = total, 0
        self.enabled = bool(globals().get('INSTALL_STAGE')) if enabled is None else enabled
        self.stream = sys.stdout
        self.animated = self.stream.isatty() and os.environ.get('TERM') != 'dumb'
        self.unicode = 'utf' in (self.stream.encoding or '').lower()
        self.frames = ('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏') if self.unicode else ('|', '/', '-', '\\')
        self.frame = 0
        self.stopped = threading.Event()
        self.thread = None

    def update(self, completed):
        with _PROGRESS_LOCK:
            self.completed = max(0, completed)

    def detail(self):
        elapsed = max(0, time.monotonic() - self.started)
        duration = f'{elapsed:.1f}s' if elapsed < 60 else f'{int(elapsed)//60}m {int(elapsed)%60:02d}s'
        amount = ''
        if self.total:
            amount = f'{self.completed/1048576:.1f}/{self.total/1048576:.1f} MiB, {min(100, self.completed*100/self.total):.0f}%, '
        return '(' + amount + duration + ')'

    def clear(self):
        if self.animated:
            self.stream.write('\r\033[2K')
            self.stream.flush()

    def render(self):
        if self.animated:
            prefix = self.frames[self.frame % len(self.frames)]
            self.frame += 1
            detail = self.detail()
            width = shutil.get_terminal_size((80, 24)).columns
            label = self.label[:max(8, width - len(detail) - 6)]
            line = '  ' + prefix + ' ' + label + ' ' + detail
            self.stream.write('\r\033[2K' + line[:max(1, width - 1)])
        else:
            self.stream.write('  [WAIT] ' + self.label + ' ' + self.detail() + '\n')
        self.stream.flush()

    def tick(self):
        interval = 0.12 if self.animated else self.heartbeat_seconds
        while not self.stopped.wait(interval):
            try:
                with _PROGRESS_LOCK:
                    self.render()
            except (OSError, ValueError):
                self.stopped.set()  # A closed terminal must not leave a noisy thread.

    def __enter__(self):
        global _ACTIVE_PROGRESS
        with _PROGRESS_LOCK:
            if not self.enabled or _ACTIVE_PROGRESS is not None:
                self.enabled = False
                return self
            self.started = time.monotonic()
            _ACTIVE_PROGRESS = self
            self.render()
            self.thread = threading.Thread(target=self.tick, name='wholly-setup-progress', daemon=True)
            self.thread.start()
        return self

    def __exit__(self, kind, error, traceback):
        global _ACTIVE_PROGRESS, LAST_FAILED_OPERATION
        if not self.enabled:
            return False
        self.stopped.set()
        if self.thread:
            self.thread.join(timeout=2)
        with _PROGRESS_LOCK:
            _ACTIVE_PROGRESS = None
            self.clear()
            status = ('✓' if kind is None else '✗') if self.animated and self.unicode else ('[OK]' if kind is None else '[FAIL]')
            if self.animated and 'NO_COLOR' not in os.environ:
                status = ('\033[32m' if kind is None else '\033[31m') + status + '\033[0m'
            self.stream.write('  ' + status + ' ' + self.label + ' ' + self.detail() + '\n')
            self.stream.flush()
            if kind is not None:
                LAST_FAILED_OPERATION = self.label
        return False


# Also embedded in the bootstrap before downloading any executable Python.
GITHUB_REPOSITORY = 'whollycrypto-com/whollycrypto'
GITHUB_DOWNLOAD = 'https://github.com/' + GITHUB_REPOSITORY + '/releases/'
GITHUB_ASSET_HOSTS = frozenset({'release-assets.githubusercontent.com', 'objects.githubusercontent.com'})


class ReleaseUnavailable(Failure):
    pass


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        fail('Release downloads must not redirect to another URL.')


class GitHubRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parsed = urllib.parse.urlsplit(newurl)
        if (parsed.scheme != 'https' or parsed.username or parsed.password
                or parsed.netloc != parsed.hostname or parsed.fragment
                or req.get_method() != 'GET'
                or any(key.lower() in {'authorization', 'cookie'} for key in req.headers)):
            fail('Unsafe GitHub release redirect. Nothing was installed.')
        if parsed.hostname == 'github.com':
            if not parsed.path.startswith('/' + GITHUB_REPOSITORY + '/releases/download/') or parsed.query:
                fail('GitHub redirect left the official release repository.')
        elif parsed.hostname not in GITHUB_ASSET_HOSTS:
            fail('GitHub redirect left the allowed release asset hosts.')
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def github_release_url(path):
    if path == '/channels/stable.json':
        return GITHUB_DOWNLOAD + 'latest/download/manifest.json'
    match = re.fullmatch(r'/merchant/((?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*))/([A-Za-z0-9_.-]+)', path)
    if not match:
        return None
    version, name = match.groups()
    if name not in {'manifest.json', 'installer.py', 'whollycrypto-' + version + '-linux-x86_64.tar.gz'}:
        return None
    return GITHUB_DOWNLOAD + 'download/v' + version + '/' + name


def release_candidates(path):
    if (not isinstance(path, str) or not path.startswith('/') or path.startswith('//')
            or not re.fullmatch(r'[A-Za-z0-9_./-]+', path)
            or any(part in {'.', '..', ''} for part in path.split('/')[1:])):
        fail('Invalid release URL.')
    result = [(ORIGIN + path, False)]
    mirror = github_release_url(path)
    if mirror:
        result.append((mirror, True))
    return result


def download_one(url, destination, limit, *, github=False, expected_size=None, digest=None, on_progress=None):
    request = urllib.request.Request(url, headers={'User-Agent': 'WhollyCrypto-Updater/2',
                                                            'Accept-Encoding': 'identity'})
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), GitHubRedirect() if github else NoRedirect())
    size = 0
    if on_progress is not None:
        on_progress(0)  # Each provider retry starts at zero; partial files are discarded.
    checksum = hashlib.sha256()
    # Never expose a partial download at the requested destination, including
    # a primary-host response which failed halfway through its body.
    if os.path.lexists(destination):
        fail('Release download destination already exists.')
    temporary = None
    try:
        with opener.open(request, timeout=10) as response:
            if response.status != 200:
                fail('Release server did not return a file.')
            descriptor, temporary = tempfile.mkstemp(prefix='.release-download.', dir=Path(destination).parent)
            deadline = time.monotonic() + 600
            with os.fdopen(descriptor, 'wb') as output:
                while True:
                    block = response.read(65536)
                    if not block:
                        break
                    size += len(block)
                    if size > limit or time.monotonic() > deadline:
                        fail('Release download exceeded its size or time limit.')
                    checksum.update(block)
                    output.write(block)
                    if on_progress is not None:
                        on_progress(size)
                output.flush()
                os.fsync(output.fileno())
            if expected_size is not None and size != expected_size:
                fail('Release file size does not match the signed manifest.')
            if digest is not None and checksum.hexdigest() != digest:
                fail('Release checksum verification failed. Nothing was installed.')
            # Atomic no-clobber publication; do not replace an existing file/link.
            os.link(temporary, destination)
    except urllib.error.HTTPError as error:
        # Include CDN-origin errors such as Cloudflare 520/521/522/523/524.
        if error.code not in {404, 408, 429} and not 500 <= error.code <= 599:
            fail('Release host refused the download (HTTP ' + str(error.code) + ').')
        raise ReleaseUnavailable('Release host is unavailable.') from None
    except (urllib.error.URLError, TimeoutError, ConnectionError, http.client.HTTPException):
        raise ReleaseUnavailable('Release host is unavailable.') from None
    finally:
        if temporary is not None:
            os.unlink(temporary)


def download(path, destination, limit, *, expected_size=None, digest=None, on_progress=None):
    for url, github in release_candidates(path):
        try:
            download_one(url, destination, limit, github=github, expected_size=expected_size, digest=digest, on_progress=on_progress)
            return
        except ReleaseUnavailable:
            if not github and github_release_url(path):
                say('Primary release host unavailable; trying the official GitHub mirror.')
    fail('Both release sources are unavailable. Check network access and retry. Nothing was installed.')


def fetch(path, maximum, on_progress=None):
    destination = root / ('download-' + hashlib.sha256(path.encode()).hexdigest())
    download(path, destination, maximum, on_progress=on_progress)
    return destination.read_bytes()

try:
    with Progress('Download and verify release signature', enabled=True):
        envelope = json.loads(fetch('/channels/stable.json', 65536))
        payload = envelope['signed']
        (root / 'release-signing.pub').write_text(public_key)
        (root / 'manifest.json').write_bytes(json.dumps(payload, sort_keys=True, separators=(',', ':'), ensure_ascii=True).encode())
        signature = base64.b64decode(envelope['signature'], validate=True)
        if not 32 <= len(signature) <= 512:
            raise RuntimeError('Invalid signature size')
        (root / 'manifest.sig').write_bytes(signature)
        subprocess.run(['openssl', 'dgst', '-sha256', '-verify', str(root / 'release-signing.pub'),
                        '-signature', str(root / 'manifest.sig'), str(root / 'manifest.json')],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=10)
        version = payload['version']
        if payload['format'] != 1 or payload['channel'] != 'stable' or not re.fullmatch(r'\d+\.\d+\.\d+', version):
            raise RuntimeError('Unsupported manifest')
        installer = payload['installer']
        if installer['path'] != '/merchant/' + version + '/installer.py':
            raise RuntimeError('Invalid installer path')
        if not 1 <= installer['size'] <= 1048576 or not re.fullmatch(r'[a-f0-9]{64}', installer['sha256']):
            raise RuntimeError('Invalid installer metadata')
    with Progress('Download and verify signed installer', total=installer['size'], enabled=True) as task:
        content = fetch(installer['path'], installer['size'], on_progress=task.update)
        if len(content) != installer['size'] or hashlib.sha256(content).hexdigest() != installer['sha256']:
            raise RuntimeError('Installer checksum does not match its signed manifest')
        (root / 'installer.py').write_bytes(content)
    print('[OK] Release signature and installer checksum verified. Wholly Crypto ' + version, flush=True)
except Exception:
    print('Wholly Crypto: could not verify the signed installer. Nothing was installed.', file=sys.stderr)
    sys.exit(1)
PY
# The signed installer prints its own precise error; avoid a duplicate shell error.
trap - ERR
python3 -I "$bootstrap_dir/installer.py" install --signing-key "$bootstrap_dir/release-signing.pub" "$@"

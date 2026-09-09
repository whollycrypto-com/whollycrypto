# Wholly Crypto

Self-hosted, non-custodial crypto payments for merchants.

This is the official **merchant release distribution** repository, not an
application source repository. Wholly Crypto is proprietary software.

- [Website](https://www.whollycrypto.com/)
- [Documentation](https://www.whollycrypto.com/documentation/)
- [API documentation](https://www.whollycrypto.com/api/)
- [Latest release](https://github.com/whollycrypto-com/whollycrypto/releases/latest)
- [Primary download server](https://releases.whollycrypto.com/)

## Install

Run as root on a fresh, dedicated, supported Linux x86-64 VPS with systemd.
Read the [requirements](https://www.whollycrypto.com/documentation/) first.

```bash
bash -c 'wholly_setup=$(curl -fsSL --connect-timeout 10 --max-time 60 https://releases.whollycrypto.com/setup_wholly.sh) || wholly_setup=$(curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/whollycrypto-com/whollycrypto/main/setup_wholly.sh) || exit 1; exec bash -c "$wholly_setup" -- "$@"' --
```

The command downloads the complete bootstrap from the primary server or GitHub
before running it. The installer also falls back to GitHub for signed metadata
and release files. No GitHub account or token is needed to install or update.
Append `--check` to check compatibility without installing, or `--help` for options.
The initial bootstrap trusts HTTPS; inspect the script before running it as root.

## Update

```bash
whollycrypto update --check
whollycrypto update
```

Starting with 0.1.20, updates automatically try GitHub if the primary host is
unavailable. Older installations must update once while the primary host is
reachable to gain this support. Signature, checksum and downgrade checks remain
enabled on both hosts. Billing and update eligibility rules are unchanged.

## Files and licensing

GitHub Releases contains the same verified merchant packages, signed manifests,
checksums and release notes as the primary download server. Repository files are
limited to these instructions, install/update launchers and public license/key
information. Application source, internal systems, credentials and signing
private keys are never published here.

See [LICENSE.txt](LICENSE.txt) and the [license terms](https://www.whollycrypto.com/terms/).
Third-party licenses remain applicable; notices are included in each package.
GitHub's automatically generated “Source code” archives contain only this small
public distribution repository, not the merchant application source.

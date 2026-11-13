<p align="center">
  <a href="https://www.whollycrypto.com/"><img src="https://www.whollycrypto.com/apple-touch-icon.png" alt="Wholly Crypto logo" width="88" height="88"></a>
</p>

<h1 align="center">Wholly Crypto: Self-Hosted Crypto Payment Gateway</h1>

<p align="center"><strong>Your server. Your wallets. Your crypto checkout.</strong></p>
<p align="center">Accept Bitcoin and stablecoins, offer fiat-to-crypto payments and automate what happens after checkout.</p>

<p align="center">
  <a href="https://github.com/whollycrypto-com/whollycrypto/releases/latest"><img src="https://img.shields.io/github/v/release/whollycrypto-com/whollycrypto?label=merchant%20release&amp;color=16724d" alt="Latest merchant release"></a>
  <a href="https://www.whollycrypto.com/documentation/#requirements"><img src="https://img.shields.io/badge/self--hosted-Linux-16724d" alt="Self-hosted on Linux"></a>
  <a href="https://www.whollycrypto.com/demo/"><img src="https://img.shields.io/badge/checkout-try%20the%20demo-16724d" alt="Try the checkout demo"></a>
</p>

<p align="center">
  <a href="https://www.whollycrypto.com/">Website</a> ·
  <a href="https://www.whollycrypto.com/features/">Features</a> ·
  <a href="https://www.whollycrypto.com/documentation/">Documentation</a> ·
  <a href="https://www.whollycrypto.com/api/">API</a> ·
  <a href="https://www.whollycrypto.com/demo/">Checkout demo</a> ·
  <a href="https://github.com/whollycrypto-com/whollycrypto/issues">Issues &amp; ideas</a>
</p>

Wholly Crypto is a **self-hosted, non-custodial crypto payment processor** for
Bitcoin, Ethereum, Solana, USDT, USDC and payments across **30 blockchain networks**.
Run it on your Linux server, accept crypto into merchant-controlled wallets and
manage checkout, invoices, sweeps and optional exchange conversion from one console.
Customers can also use an approved **fiat-to-crypto on-ramp** without owning crypto first.

This is the official **merchant release distribution** repository. The merchant
application is proprietary; the official SDKs and shop plugins have their own licenses.

[Features](#what-you-can-do) · [Fiat & crypto](#fiat-to-crypto-and-crypto-to-fiat) · [Plugins & SDKs](#plugins--sdks) · [Install](#install) · [Guides](#guides-and-tutorials) · [Pricing](#how-pricing-works)

<p align="center">
  <a href="https://www.whollycrypto.com/features/"><img src="https://www.whollycrypto.com/assets/screenshots/merchant-dashboard.png" alt="Wholly Crypto merchant dashboard showing crypto payment revenue, projects and store reports with example data" width="900"></a><br>
  <sub>Merchant dashboard with example data.</sub>
</p>

## What you can do

| Feature | How it helps |
| --- | --- |
| **Bitcoin, stablecoins and tokens** | Choose native coins and supported tokens per store. A catalog of up to 3,000 assets helps match tokens to networks. Add supported custom EVM/Solana tokens with fixed USD or matching DEX pricing. |
| **Bitcoin Lightning** | Receive through your own LND node or a compatible Nostr Wallet Connect connection. Custody, liquidity and receiving capacity depend on the connected wallet or node. |
| **Branded checkout** | Configure logos, colors, languages, messages, redirects and hosted or embedded checkout. Customers see payment QR codes, remaining amounts and confirmation progress. |
| **Projects, stores and invoices** | Separate businesses and teams. Create manual or API invoices with fiat pricing, metadata, confirmation targets, expiry, underpayment tolerance and exchange-rate spread. |
| **Payment links and POS** | Use reusable links, customer-entered amounts, donations or a point-of-sale screen. Scheduled email requests ask customers to pay; they do not debit their wallets automatically. |
| **Wallets and automatic sweeps** | Track native-coin/token balances, save destinations in the address book, back up wallets, send supported assets or automate transfers. Supported token workflows can fund native gas first. |
| **Payment reconciliation** | Review underpaid, overpaid, late or ambiguous payments. Search notification history, inspect delivery details and retry failed IPN/webhooks. |
| **Reporting and alerts** | See revenue across projects/stores, use accounting exports and configure merchant notifications. |
| **Account and API security** | TOTP two-factor authentication, project-scoped users/API keys, IP restrictions, signed updates and CLI diagnostics/recovery tools. |

Blockchain nodes run separately. Connect your own nodes or public providers and
fallbacks through HTTPS/WSS. Scanner compatibility and public-provider limits
still matter. Direct crypto checkout requires no Wholly Crypto customer account
or built-in identity check; third-party services have their own requirements.

[Supported networks](https://www.whollycrypto.com/networks/) ·
[Lightning](https://www.whollycrypto.com/documentation/lightning/) ·
[Custom tokens](https://www.whollycrypto.com/documentation/#wallets) ·
[No-KYC crypto checkout](https://www.whollycrypto.com/no-kyc/) ·
[Public node catalog](https://www.whollycrypto.com/public-node-catalog/)

## Fiat-to-crypto and crypto-to-fiat

### Let customers pay in fiat

Offer optional **fiat-to-crypto checkout** alongside crypto payments. Connect your
own approved accounts with **Coinflow, Changelly, Paybis, Guardarian, Banxa,
Transak, MoonPay, Coinbase Onramp or Onramper**. Individual services have their
own integrations; Onramper is also available as an aggregator.

Each connection has separate credentials, a purchase buffer and per-store
controls. Customers choose an available provider/payment method and review its
quote. The initial receiving route is **native USDC on Base**. Provider approval,
countries, supported payment methods, limits, fees and KYC vary. An invoice settles
only after the crypto arrives and meets its confirmation policy.

[On-ramp providers](https://www.whollycrypto.com/on-ramp/) ·
[Fiat-to-crypto setup tutorial](https://www.whollycrypto.com/tutorials/fiat-to-crypto/)

### Convert received crypto through an exchange

Connect **Kraken, Binance or Coinbase**. Send supported assets to your exchange,
then optionally market-convert a matched, credited deposit into **USD, EUR, GBP**
or another available fiat currency or crypto asset. Available networks, direct
markets, minimums and fees depend on your exchange account. The exchange holds
deposited funds and may require KYC; fiat stays in that account. Bank withdrawals
are separate.

[Crypto-to-fiat conversion](https://www.whollycrypto.com/crypto-to-fiat/) ·
[Automatic exchange tutorial](https://www.whollycrypto.com/tutorials/exchange-conversion/)

<details>
<summary>View the hosted checkout preview</summary>

<p align="center">
  <a href="https://www.whollycrypto.com/demo/"><img src="https://www.whollycrypto.com/assets/screenshots/hosted-checkout.png" alt="Wholly Crypto hosted checkout showing a safe, non-payable preview with chain and asset selection" width="460"></a><br>
  <sub>Non-payable checkout preview. Open the interactive demo to explore crypto and fiat payment flows.</sub>
</p>

</details>

## Merchant mode, Operator mode and Marketplace

**Merchant mode** runs your own projects and stores. **Operator mode** lets you
host separate merchant accounts, set their prepaid processing fees and automate
onboarding through the Operator API. Hosted merchants share your server and must
trust the operator, who can access their wallet keys. Installation mode is chosen
at first setup and is permanent.

**Marketplace payments** support shared-cart invoices, vendor allocations,
commissions and controlled payouts for **Bitcoin and supported EVM assets**.
Customers pay a project wallet first; approved vendor payouts follow. Keep funds
available for network fees. This is separate from giving a merchant a hosted account.

[Merchant or Operator Mode](https://www.whollycrypto.com/tutorials/merchant-or-operator-mode/) ·
[Marketplace overview](https://www.whollycrypto.com/marketplace/) ·
[Crypto Marketplace tutorial](https://www.whollycrypto.com/tutorials/crypto-marketplace/)

## Plugins & SDKs

### Shop plugins

| Plugin | Compatibility | Links |
| --- | --- | --- |
| **WooCommerce** | WordPress 6.5+, WooCommerce 9.0+, PHP 8.1+; Classic checkout, Checkout Blocks and HPOS | [GitHub](https://github.com/whollycrypto-com/whollycrypto-woocommerce) · [Guide](https://www.whollycrypto.com/plugins/woocommerce/) · [Download](https://github.com/whollycrypto-com/whollycrypto-woocommerce/releases/latest) |
| **WHMCS** | Supported WHMCS installation, PHP 8.1+ | [GitHub](https://github.com/whollycrypto-com/whollycrypto-whmcs) · [Guide](https://www.whollycrypto.com/plugins/whmcs/) · [Download](https://github.com/whollycrypto-com/whollycrypto-whmcs/releases/latest) |
| **BTCPay Server** | 2.4.4+; tested on 2.4.4; hosted or optional iframe checkout | [GitHub](https://github.com/whollycrypto-com/whollycrypto-btcpayserver) · [Guide](https://www.whollycrypto.com/plugins/btcpayserver/) · [Download](https://github.com/whollycrypto-com/whollycrypto-btcpayserver/releases/latest) |
| **PrestaShop** | 9.x, PHP 8.1+ | [GitHub](https://github.com/whollycrypto-com/whollycrypto-prestashop) · [Guide](https://www.whollycrypto.com/plugins/prestashop/) · [Download](https://github.com/whollycrypto-com/whollycrypto-prestashop/releases/latest) |
| **OpenCart** | 4.1.x, PHP 8.1+ | [GitHub](https://github.com/whollycrypto-com/whollycrypto-opencart) · [Guide](https://www.whollycrypto.com/plugins/opencart/) · [Download](https://github.com/whollycrypto-com/whollycrypto-opencart/releases/latest) |
| **Shopware 5** | 5.7.20+ in the 5.7 series, PHP 7.4+ | [GitHub](https://github.com/whollycrypto-com/whollycrypto-shopware5) · [Guide](https://www.whollycrypto.com/plugins/shopware/) · [Download](https://github.com/whollycrypto-com/whollycrypto-shopware5/releases/latest) |
| **Shopware 6** | 6.7, PHP 8.2+ | [GitHub](https://github.com/whollycrypto-com/whollycrypto-shopware6) · [Guide](https://www.whollycrypto.com/plugins/shopware/) · [Download](https://github.com/whollycrypto-com/whollycrypto-shopware6/releases/latest) |
| **Magento 2** | 2.4, PHP 8.2+; standard Magento/Luma checkout | [GitHub](https://github.com/whollycrypto-com/whollycrypto-magento) · [Guide](https://www.whollycrypto.com/plugins/magento/) · [Download](https://github.com/whollycrypto-com/whollycrypto-magento/releases/latest) |

Plugins use your own Wholly Crypto installation and verify payment notifications
against its API. Wallet keys stay out of the shop. Check each plugin's tested
versions and supported workflows, then test your shop before going live.

### Developer SDKs

| SDK | Installation | Quickstart and examples |
| --- | --- | --- |
| **PHP 7.4+** | `composer require whollycrypto/php-sdk` or manual installation | [GitHub](https://github.com/whollycrypto-com/whollycrypto-php-sdk) · [Quickstart](https://www.whollycrypto.com/sdks/php/) · [Examples](https://github.com/whollycrypto-com/whollycrypto-php-sdk/tree/main/examples) |
| **Python 3.10+** | `python -m pip install whollycrypto` or direct source usage | [GitHub](https://github.com/whollycrypto-com/whollycrypto-python-sdk) · [Quickstart](https://www.whollycrypto.com/sdks/python/) · [Examples](https://github.com/whollycrypto-com/whollycrypto-python-sdk/tree/main/examples) |
| **JavaScript / TypeScript** | `npm install whollycrypto`; Node.js 22+, ESM/CommonJS; manual use available | [GitHub](https://github.com/whollycrypto-com/whollycrypto-node-sdk) · [Quickstart](https://www.whollycrypto.com/sdks/node/) · [Examples](https://github.com/whollycrypto-com/whollycrypto-node-sdk/tree/main/examples) |
| **Swift** | Swift Package Manager; Swift 5.9+, Xcode, iOS 15+ / macOS 12+ | [GitHub](https://github.com/whollycrypto-com/whollycrypto-swift-sdk) · [Quickstart](https://www.whollycrypto.com/sdks/swift/) · [Examples](https://github.com/whollycrypto-com/whollycrypto-swift-sdk/tree/main/Examples) |

Swift installation currently tracks `main`; see its README for build/test status.
All SDKs are MIT licensed. Plugins carry their own licenses and compatibility notes.

### API, IPN, webhooks and AI assistants

Create invoices, select accepted chains/tokens and verify payment notifications
through your own installation's API. Keep shared API credentials and signing
secrets on your backend, including when building customer-facing mobile apps.
Copy Project and Store UUIDs from **Store → Basic → API IDs**.

The built-in **Model Context Protocol (MCP) server** connects an AI assistant to
approved projects through OAuth. Read invoices/balances or separately permit
invoice creation; permissions can be revoked. Wallet-secret exports and spending
are outside the MCP tool set.

[Merchant API reference](https://www.whollycrypto.com/api/) ·
[IPN & webhook guide](https://www.whollycrypto.com/documentation/#delivery-history) ·
[MCP setup](https://www.whollycrypto.com/documentation/mcp/)

## Install

Run as root on a fresh, dedicated, supported **Linux x86-64 VPS with systemd**.
The native installation uses PostgreSQL and Nginx. Blockchain nodes run separately.

| | Minimum for light use | Recommended |
| --- | --- | --- |
| Server | 1 vCPU · 2 GB RAM · 20 GB SSD | 2 vCPU · 4 GB RAM · 60 GB SSD |

Read the [supported distributions and requirements](https://www.whollycrypto.com/documentation/#requirements).
These sizes assume a minimal server image. Allow inbound **TCP 80/443** in both
VPS and provider firewalls and keep SSH access. With Cloudflare, use DNS-only
during installation; turn the proxy back on after domain validation finishes.

```bash
bash -c 'wholly_setup=$(curl -fsSL --connect-timeout 10 --max-time 60 https://releases.whollycrypto.com/setup_wholly.sh) || wholly_setup=$(curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/whollycrypto-com/whollycrypto/main/setup_wholly.sh) || exit 1; exec bash -c "$wholly_setup" -- "$@"' --
```

The complete bootstrap downloads from the primary server or GitHub before it
runs. Signed metadata and release downloads also have GitHub fallback; no GitHub
account is needed. Append `--check` to check compatibility without installing or
`--help` for options. The initial bootstrap trusts HTTPS; inspect it before running as root.

Choose your domains, default fiat currency and console protection. `merchant.*`,
`pay.*` and `api.*` are the defaults; custom names are supported. Register the
administrator, choose your mode, create a store, back up wallets and enable payment
methods. New installations receive a one-time **$10 welcome credit**.

### Optional Docker installation

Prefer **Docker Compose**? Use the [official Docker integration](https://github.com/whollycrypto-com/whollycrypto-docker)
and [Docker installation guide](https://www.whollycrypto.com/documentation/docker/).
It uses verified, prebuilt merchant releases and persistent application/database data.

## Guides and tutorials

- [Install on a VPS](https://www.whollycrypto.com/tutorials/install/) and [create your first project, store and invoice](https://www.whollycrypto.com/tutorials/first-payment/).
- [Receive USDT/USDC and sweep to a cold wallet](https://www.whollycrypto.com/tutorials/receiving-stablecoins/) or [set up automatic sweeps](https://www.whollycrypto.com/tutorials/auto-sweep/).
- [Use the API, IPN and webhooks](https://www.whollycrypto.com/tutorials/api-notifications/).
- [Explore all tutorials](https://www.whollycrypto.com/tutorials/), [network guides](https://www.whollycrypto.com/networks/) and [processor comparisons](https://www.whollycrypto.com/compare/).

## How pricing works

The default processing fee is **1% of the invoice's original fiat value**,
deducted from prepaid processing credits as invoices settle. Your assigned rate
applies. A $100 invoice uses $1 of credit at 1%.

**Your customer payment is not split with us.** Customer funds go to your wallets;
processing credits are topped up separately. Hosting, network, exchange and
on-ramp provider fees are separate.

**Low credits never block customer payments.** You can still create checkouts,
receive payments and track confirmations. IPN/webhooks, Sweep, new exchange
conversions, new projects/stores and installing new versions pause until usable
credit is restored. Backups, recovery and update checks remain available.
Fees continue to accrue.

[Pricing](https://www.whollycrypto.com/#pricing) ·
[Processing-credit guide](https://www.whollycrypto.com/documentation/#credits)

## Update

```bash
whollycrypto update --check
whollycrypto update
```

Updates verify signatures and checksums and use GitHub if the primary host is
unavailable. Keep independent backups of wallets, settings and the database.
See the [update tutorial](https://www.whollycrypto.com/tutorials/update/).

<details>
<summary>Updating an older installation</summary>

GitHub fallback is supported from 0.1.20. Older installations need one update
while the primary server is reachable. For 0.1.31 or earlier, use the signed
standalone updater once to avoid the old background-worker timing issue:

```bash
bash <(curl -fsSL https://releases.whollycrypto.com/update_wholly.sh)
```

It verifies the latest updater with the installed key before running. Afterwards,
use `whollycrypto update` normally. Signature, downgrade and update eligibility
checks remain enabled.

</details>

## Files, licensing and support

This repository contains only public distribution instructions, install/update
launchers, a public verification key and license information. GitHub Releases
holds verified merchant packages, signed manifests, checksums and public release
notes. The merchant application source and private systems are not published here.
GitHub's automatic **Source code** archives contain this distribution repository.

See [LICENSE.txt](LICENSE.txt) and the [software license terms](https://www.whollycrypto.com/terms/).
Third-party notices are included in each package. SDKs and plugins have their own licenses.

[Report a bug or request a feature](https://github.com/whollycrypto-com/whollycrypto/issues) ·
[Contact us privately](https://www.whollycrypto.com/contact/?category=technical) ·
[Join Telegram](https://t.me/whollycrypto_com)

Never post credentials, private keys, recovery phrases or customer details in an issue.

## Supported by real merchants

These merchants use Wholly Crypto and support its development.

| [CryptoTraveler](https://www.cryptotraveler.com/) | [Blacktel](https://www.blacktel.io/) | [Verifyr](https://www.verifyr.com/) |
| :---: | :---: | :---: |
| <a href="https://www.cryptotraveler.com/"><img src="https://www.whollycrypto.com/assets/supporters/cryptotraveler.png" alt="CryptoTraveler" width="48" height="48"></a> | <a href="https://www.blacktel.io/"><img src="https://www.whollycrypto.com/assets/supporters/blacktel.png" alt="Blacktel" width="48" height="48"></a> | <a href="https://www.verifyr.com/"><img src="https://www.whollycrypto.com/assets/supporters/verifyr.png" alt="Verifyr" width="48" height="48"></a> |
| Hotels, flights and travel eSIMs with crypto | Virtual numbers, calls, SMS and travel eSIMs | Team 2FA and authentication workflows |

Using Wholly Crypto? [Become a supporter merchant and get listed](https://www.whollycrypto.com/contact/?category=supporter).

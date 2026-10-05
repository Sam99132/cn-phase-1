# dnsmasq Configuration

**Machine:** Mac 1 (10.7.17.112)

## Overview

dnsmasq provides private DNS resolution on the local LAN. It maps the `.test` domain hostnames to Mac 2's IP address so that all three machines can resolve `app.team2.test` and `api.team2.test` without relying on public DNS.

## DNS Records

| Hostname         | Resolves To   | Purpose                        |
| ---------------- | ------------- | ------------------------------ |
| `app.team2.test` | `10.7.9.236`  | nginx edge server (Mac 2)      |
| `api.team2.test` | `10.7.9.236`  | nginx edge server (Mac 2)      |

## Installation (macOS)

```bash
brew install dnsmasq
```

## Configuration

Add the following entries to the dnsmasq configuration file. The default location on macOS with Homebrew is:

```
/usr/local/etc/dnsmasq.conf
```

or

```
/opt/homebrew/etc/dnsmasq.conf
```

### Required entries

```conf
# ── Private DNS for Computer Networks Phase 1 ──
# Resolve .test hostnames to the nginx edge server (Mac 2)
address=/app.team2.test/10.7.9.236
address=/api.team2.test/10.7.9.236

# Listen on all interfaces so other machines on the LAN can use this DNS
listen-address=0.0.0.0

# Bind only to specific interfaces (optional, for security)
# interface=en0
```

## Starting dnsmasq

```bash
# Start via Homebrew services
sudo brew services start dnsmasq

# Or run directly
sudo dnsmasq --no-daemon
```

> **Note:** dnsmasq binds to port 53 (UDP/TCP), which requires root privileges on macOS.

## Configuring Client Machines to Use This DNS

On each Mac that needs to resolve `app.team2.test`, set the DNS server to Mac 1's IP:

### macOS System Preferences

1. Open **System Settings → Network → Wi-Fi → Details → DNS**
2. Add `10.7.17.112` as the DNS server
3. Click **OK** and **Apply**

### Temporary override (for testing)

```bash
# Verify resolution without changing system DNS
dig @10.7.17.112 app.team2.test
```

## Verifying

```bash
# Query the DNS server directly
dig @10.7.17.112 app.team2.test

# Expected output should contain:
# app.team2.test.    0    IN    A    10.7.9.236
```

```bash
# Also verify the second hostname
dig @10.7.17.112 api.team2.test

# Expected: api.team2.test.    0    IN    A    10.7.9.236
```

# TLS / HTTPS Configuration

**Machine:** Mac 2 (10.7.9.236)

## Overview

TLS (Transport Layer Security) encrypts traffic between the client and nginx. nginx terminates TLS on port 8443, then forwards plain HTTP to the backend pool. This means:

- **Client ↔ nginx:** encrypted (HTTPS)
- **nginx ↔ backends:** unencrypted (HTTP) — acceptable because nginx and backends are on a trusted private LAN

## Certificate Requirements

For the final demonstration, the project requires **proper certificate validation** (no `curl -k` / `--insecure`). This means the client must trust the CA that signed the server certificate.

### Approach: Self-Signed CA

We create our own Certificate Authority (CA), use it to sign the server certificate, and install the CA certificate as trusted on the client machine.

## Certificate Generation Steps

Run the following commands on Mac 2 (or any machine, then copy the files to Mac 2):

### 1. Create a private CA

```bash
# Generate CA private key
openssl genrsa -out ca.key 4096

# Generate CA certificate (valid for 365 days)
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 \
  -out ca.crt \
  -subj "/C=PK/ST=Punjab/L=Lahore/O=Team2-CN/CN=Team2 Private CA"
```

### 2. Create the server certificate

```bash
# Generate server private key
openssl genrsa -out app.team2.test.key 2048

# Create a Certificate Signing Request (CSR)
openssl req -new -key app.team2.test.key \
  -out app.team2.test.csr \
  -subj "/C=PK/ST=Punjab/L=Lahore/O=Team2-CN/CN=app.team2.test"
```

### 3. Create a SAN (Subject Alternative Name) extension file

Create a file named `san.ext`:

```
authorityKeyIdentifier=keyIdentifier,issuerSerialNumber
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = app.team2.test
DNS.2 = api.team2.test
```

### 4. Sign the server certificate with the CA

```bash
openssl x509 -req -in app.team2.test.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out app.team2.test.crt -days 365 -sha256 \
  -extfile san.ext
```

### 5. Install files on Mac 2

```bash
sudo mkdir -p /usr/local/etc/nginx/ssl
sudo cp app.team2.test.crt /usr/local/etc/nginx/ssl/
sudo cp app.team2.test.key /usr/local/etc/nginx/ssl/
```

### 6. Trust the CA on the client machine (Mac 1)

```bash
# Copy ca.crt to Mac 1, then:
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain ca.crt
```

After this, `curl https://app.team2.test:8443/api/status` will work **without** the `-k` flag.

## Files

| File                  | Purpose                     | Commit to Git? |
| --------------------- | --------------------------- | -------------- |
| `ca.key`              | CA private key              | **NO**         |
| `ca.crt`              | CA certificate (public)     | Optional       |
| `app.team2.test.key`  | Server private key          | **NO**         |
| `app.team2.test.csr`  | Certificate signing request | No (temporary) |
| `app.team2.test.crt`  | Server certificate (public) | Optional       |
| `san.ext`             | SAN extension config        | Yes            |

> **Security:** Private keys (`.key` files) must never be committed to Git. The `.gitignore` in this repository excludes `*.key`, `*.pem`, `*.crt`, and `*.csr` by default.

## TLS Handshake (Conceptual)

When a client connects to `https://app.team2.test:8443`:

```
Client                                  nginx (Mac 2)
  │                                        │
  │──── ClientHello ──────────────────────▶│
  │     (supported TLS versions, ciphers)  │
  │                                        │
  │◀──── ServerHello ─────────────────────│
  │      (selected TLS version, cipher)    │
  │                                        │
  │◀──── Certificate ─────────────────────│
  │      (app.team2.test.crt)              │
  │                                        │
  │◀──── ServerKeyExchange ───────────────│
  │                                        │
  │──── ClientKeyExchange ────────────────▶│
  │                                        │
  │──── ChangeCipherSpec ─────────────────▶│
  │──── Finished ─────────────────────────▶│
  │                                        │
  │◀──── ChangeCipherSpec ────────────────│
  │◀──── Finished ────────────────────────│
  │                                        │
  │◀═══════ Encrypted Application Data ═══▶│
```

After the handshake completes, all HTTP traffic is encrypted inside the TLS tunnel.

## End-to-End Flow

```
Client (Mac 1)
     │
     │ TCP connect to 10.7.9.236:8443
     │ TLS handshake
     │ HTTPS request (encrypted)
     ▼
nginx (Mac 2) — TLS termination
     │
     │ Plain HTTP to backend pool
     ▼
Backend A (10.7.16.15:3001)  or  Backend B (10.7.16.15:3002)
```

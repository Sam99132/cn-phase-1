# Architecture — Phase 1

## System Overview

This project demonstrates core Computer Networks concepts using a three-Mac local setup connected via a private LAN. The system implements DNS resolution, HTTPS/TLS, reverse proxying, round-robin load balancing, HTTP caching, and packet-level verification.

**There is no cloud/AWS infrastructure.** Everything runs on local machines connected to the same Wi-Fi network.

## Machine Roles

| Machine | IP Address    | Role                        | Ports      |
| ------- | ------------- | --------------------------- | ---------- |
| Mac 1   | 10.7.17.112   | DNS Server + Client         | 53         |
| Mac 2   | 10.7.9.236    | nginx + TLS + Load Balancer | 8443       |
| Mac 3   | 10.7.16.15    | Backend A + Backend B       | 3001, 3002 |

> **Why three Macs instead of four?** Our team combined Backend A and Backend B on a single physical machine (Mac 3), running them as separate services on different TCP ports. This is functionally equivalent to having four separate machines — each backend has its own process, port, and network identity.

## Network Topology

```
                    Private LAN / Wi-Fi
          ┌──────────────┼──────────────┐
          │              │              │
      ┌───┴───┐     ┌───┴───┐     ┌───┴───┐
      │ Mac 1 │     │ Mac 2 │     │ Mac 3 │
      │       │     │       │     │       │
      │ DNS   │     │ nginx │     │ Bknd A│
      │Client │     │ TLS   │     │ :3001 │
      │       │     │ :8443 │     │       │
      │       │     │       │     │ Bknd B│
      │       │     │       │     │ :3002 │
      └───────┘     └───────┘     └───────┘
     10.7.17.112   10.7.9.236   10.7.16.15
```

## End-to-End Request Flow

When a client on Mac 1 accesses `https://app.team2.test:8443/api/status`:

### Step 1 — DNS Resolution (Application Layer)

```
Mac 1 Client → dnsmasq (Mac 1, port 53)
Query:  app.team2.test  A?
Answer: 10.7.9.236
Protocol: DNS over UDP, port 53
```

### Step 2 — TCP Connection (Transport Layer)

```
Mac 1 → Mac 2 (10.7.9.236:8443)
SYN →
← SYN-ACK
ACK →
Protocol: TCP, port 8443
```

### Step 3 — TLS Handshake (Security)

```
Client                               nginx (Mac 2)
  │── ClientHello ──────────────────▶│
  │◀── ServerHello ─────────────────│
  │◀── Certificate ─────────────────│  (app.team2.test.crt)
  │◀── ServerKeyExchange ───────────│
  │── ClientKeyExchange ───────────▶│
  │── ChangeCipherSpec ────────────▶│
  │── Finished ────────────────────▶│
  │◀── ChangeCipherSpec ───────────│
  │◀── Finished ───────────────────│
Protocol: TLS 1.2 / TLS 1.3
```

### Step 4 — HTTPS Request (Application Layer, encrypted)

```
Client → nginx
GET /api/status HTTP/1.1
Host: app.team2.test
(encrypted inside TLS tunnel)
```

### Step 5 — Reverse Proxy + Load Balancing

```
nginx → backend_pool (round-robin)
  → 10.7.16.15:3001 (Backend A)  ← odd requests
  → 10.7.16.15:3002 (Backend B)  ← even requests
Protocol: HTTP (plain, not encrypted)
```

### Step 6 — Backend Response

```
Backend → nginx → Client
HTTP/1.1 200 OK
X-Backend: A (or B)
Cache-Control: public, max-age=30
ETag: "..."
Content-Type: application/json

{"backend":"A","status":"ok"}
```

### Step 7 — TLS Encryption of Response

nginx encrypts the response inside the existing TLS session and sends it back to the client.

## Protocol Stack Mapping

| Layer                 | Protocol     | Port(s)       | Purpose                         |
| --------------------- | ------------ | ------------- | ------------------------------- |
| Application           | DNS          | 53 (UDP)      | Hostname resolution             |
| Application           | HTTP         | 3001, 3002    | Backend API communication       |
| Application           | HTTPS        | 8443          | Client-to-nginx communication   |
| Security/Session      | TLS 1.2/1.3  | (over 8443)   | Encryption at nginx edge        |
| Transport             | TCP          | 8443, 3001, 3002 | Reliable delivery            |
| Transport             | UDP          | 53            | DNS queries (connectionless)    |
| Network               | IP           | —             | Addressing and routing          |
| Link                  | Ethernet/Wi-Fi | —           | Physical LAN connectivity       |

## HTTP Caching

The `/api/status` endpoint on both backends supports HTTP caching:

- **`Cache-Control: public, max-age=30`** — tells clients and intermediaries that the response can be cached for 30 seconds.
- **`ETag`** — a content-based hash that enables conditional requests.
- **`If-None-Match`** — clients can send the cached ETag; if it matches, the backend returns `304 Not Modified` instead of the full response body.

### Caching Flow

```
1. Fresh request      → 200 OK + ETag + body
2. Conditional request → If-None-Match: "<etag>" → 304 Not Modified (no body)
3. Stale request      → If-None-Match: "<old-etag>" → 200 OK + new ETag + body
```

## Security Considerations

- TLS private keys are excluded from Git (`.gitignore`).
- The self-signed CA is only trusted within the project's LAN.
- Backend traffic between nginx and Mac 3 is unencrypted — acceptable for a private LAN demonstration.
- No sensitive data is transmitted by the application.

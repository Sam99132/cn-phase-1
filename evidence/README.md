# Evidence — Phase 1

This directory contains all evidence required for the Phase 1 demonstration. Each subfolder corresponds to a specific requirement area. Screenshots and captures should be placed in the appropriate folder.

> **Important:** Do not fabricate evidence. Only upload actual screenshots captured during testing on the three-Mac LAN setup.

## Evidence Checklist

- [ ] **01 — LAN Connectivity:** Ping tests between all three Macs
- [ ] **02 — DNS Resolution:** `dig` showing `app.team2.test → 10.7.9.236`
- [ ] **03 — Backend Responses:** `curl` output from Backend A (port 3001) and Backend B (port 3002)
- [ ] **04 — nginx Load Balancing:** Multiple requests showing `X-Backend` header alternating between A and B
- [ ] **05 — TLS / HTTPS:** `curl -v` output showing TLS handshake and certificate validation (no `--insecure`)
- [ ] **06 — Wireshark: DNS:** Packet capture showing DNS query for `app.team2.test` and response with `10.7.9.236`
- [ ] **07 — Wireshark: TCP:** Packet capture showing TCP three-way handshake (SYN → SYN-ACK → ACK) to port 8443
- [ ] **08 — Wireshark: TLS:** Packet capture showing TLS handshake (ClientHello, ServerHello, Certificate, encrypted data)
- [ ] **09 — HTTP Caching:** Evidence of `Cache-Control`, `ETag`, and `304 Not Modified` responses
- [ ] **10 — Failure Demonstrations:** Controlled failure scenarios showing system resilience

## Folder Structure

```
evidence/
├── README.md                      ← this file
├── 01-lan-connectivity/
├── 02-dns/
├── 03-backends/
├── 04-nginx-load-balancing/
├── 05-tls/
├── 06-wireshark-dns/
├── 07-wireshark-tcp/
├── 08-wireshark-tls/
├── 09-http-caching/
└── 10-failure-demonstrations/
```

Each subfolder contains a `README.md` describing exactly which screenshots to place there.

# Phase 1 — Demo Script

Step-by-step script for the Phase 1 demonstration. Follow this sequence to demonstrate all required features to the evaluator.

## Pre-Demo Checklist

- [ ] All three Macs are connected to the same Wi-Fi / LAN
- [ ] dnsmasq is running on Mac 1 (10.7.17.112)
- [ ] nginx is running on Mac 2 (10.7.9.236) with TLS certificates in place
- [ ] Backend A is running on Mac 3 (10.7.16.15:3001)
- [ ] Backend B is running on Mac 3 (10.7.16.15:3002)
- [ ] Mac 1 has the CA certificate trusted in its keychain
- [ ] Wireshark is installed on Mac 1

---

## Demo Step 1 — LAN Connectivity

**Machine:** Mac 1

```bash
ping -c 4 10.7.9.236    # Mac 2
ping -c 4 10.7.16.15    # Mac 3
```

**What to show:** All pings succeed with 0% packet loss.

---

## Demo Step 2 — DNS Resolution

**Machine:** Mac 1

```bash
dig @10.7.17.112 app.team2.test
dig @10.7.17.112 api.team2.test
```

**What to show:** Both hostnames resolve to `10.7.9.236`.

---

## Demo Step 3 — Backend A Direct Access

**Machine:** Mac 1 (or Mac 3)

```bash
curl -v http://10.7.16.15:3001/api/status
```

**What to show:**
- HTTP 200 response
- `X-Backend: A` header
- JSON body: `{"backend":"A","status":"ok"}`

---

## Demo Step 4 — Backend B Direct Access

**Machine:** Mac 1 (or Mac 3)

```bash
curl -v http://10.7.16.15:3002/api/status
```

**What to show:**
- HTTP 200 response
- `X-Backend: B` header
- JSON body: `{"backend":"B","status":"ok"}`

---

## Demo Step 5 — HTTPS Through nginx

**Machine:** Mac 1

```bash
curl -v https://app.team2.test:8443/api/status
```

**What to show:**
- TLS handshake succeeds (no `--insecure` flag)
- Certificate for `app.team2.test` is presented
- HTTP 200 response through nginx
- `X-Backend` header shows which backend served the request

---

## Demo Step 6 — Round-Robin Load Balancing

**Machine:** Mac 1

```bash
# Send 10 requests and observe the X-Backend header
for i in $(seq 1 10); do
  echo -n "Request $i: "
  curl -s -D - https://app.team2.test:8443/api/status -o /dev/null | grep X-Backend
done
```

Or use:
```bash
./scripts/test-load-balancing.sh
```

**What to show:** `X-Backend` alternates between `A` and `B`, demonstrating round-robin.

---

## Demo Step 7 — HTTP Caching

**Machine:** Mac 1

### Step 7a — Fresh request
```bash
curl -v https://app.team2.test:8443/api/status
```
Note the `ETag` and `Cache-Control` headers in the response.

### Step 7b — Conditional request (304)
```bash
# Replace <etag-value> with the ETag from Step 7a
curl -v -H 'If-None-Match: <etag-value>' https://app.team2.test:8443/api/status
```

**What to show:**
- Step 7a returns `200 OK` with `Cache-Control` and `ETag`
- Step 7b returns `304 Not Modified` (if the ETag matches)

---

## Demo Step 8 — Wireshark Capture

**Machine:** Mac 1 (start Wireshark before running the curl commands)

1. Start Wireshark on the Wi-Fi interface.
2. Apply a broad filter or capture everything.
3. Run:
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
4. Stop the capture.
5. Show the following in Wireshark:

### 8a — DNS packets
Filter: `dns`
Show the DNS query for `app.team2.test` and the response.

### 8b — TCP three-way handshake
Filter: `ip.addr == 10.7.9.236 && tcp.port == 8443`
Show: SYN → SYN-ACK → ACK

### 8c — TLS handshake
Filter: `tls && ip.addr == 10.7.9.236`
Show: ClientHello → ServerHello → Certificate → encrypted data

### 8d — Encrypted application data
Show: Application Data packets (no readable HTTP content = encryption working)

---

## Demo Step 9 — Failure Demonstrations

### 9a — Kill Backend A
On Mac 3, stop Backend A (port 3001). Send requests:
```bash
curl -v https://app.team2.test:8443/api/status
```
Show: all requests go to Backend B.

### 9b — Kill Backend B
Stop Backend B too. Send requests:
```bash
curl -v https://app.team2.test:8443/api/status
```
Show: nginx returns `502 Bad Gateway`.

### 9c — Restart both backends
Start Backend A and Backend B again. Show that load balancing resumes.

### 9d — DNS failure
Stop dnsmasq on Mac 1. Show that `dig app.team2.test` fails.

---

## Demo Summary

| # | Feature                 | Evidence                                  |
|---|-------------------------|-------------------------------------------|
| 1 | LAN connectivity        | Ping between all Macs                     |
| 2 | Private DNS             | `dig` resolving `.test` domain            |
| 3 | Backend A               | Direct curl to port 3001                  |
| 4 | Backend B               | Direct curl to port 3002                  |
| 5 | HTTPS / TLS             | `curl -v` without `--insecure`            |
| 6 | Load balancing          | X-Backend alternation                     |
| 7 | HTTP caching            | Cache-Control, ETag, 304                  |
| 8 | Wireshark               | DNS, TCP, TLS packet captures             |
| 9 | Failure modes           | Backend/DNS failure and recovery          |

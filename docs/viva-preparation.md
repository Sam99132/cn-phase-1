# Viva Preparation — Phase 1

Anticipated questions and concise answers for the Phase 1 viva/oral examination.

---

## Architecture & Setup

### Q: Why are you using three Macs instead of four?

We combined both backends (A and B) on a single physical machine (Mac 3) running as separate processes on different TCP ports (3001 and 3002). From a networking perspective, each backend has its own port and is addressed independently by nginx. The architecture is functionally equivalent to having four separate machines.

### Q: Why is nginx on port 8443 instead of 443?

Port 443 requires root privileges on macOS. Using port 8443 allows us to run nginx without root, which is standard practice for development and testing environments. The TLS/HTTPS behavior is identical regardless of port number.

### Q: Why use `.test` instead of a real domain?

`.test` is an IETF-reserved TLD (RFC 6761) specifically intended for testing purposes. It will never be registered in the public DNS, preventing conflicts with real domains. Using a private domain demonstrates our understanding of DNS without requiring domain registration.

---

## DNS

### Q: How does DNS resolution work in your setup?

Mac 1 runs dnsmasq, which is configured to resolve `app.team2.test` and `api.team2.test` to `10.7.9.236` (Mac 2). When a client queries this DNS server, dnsmasq responds with the configured A record. Client machines must be configured to use Mac 1 (10.7.17.112) as their DNS server.

### Q: What transport protocol does DNS use?

DNS primarily uses UDP on port 53 for standard queries. TCP port 53 is used for zone transfers and responses larger than 512 bytes (or 4096 bytes with EDNS).

### Q: What happens if the DNS server goes down?

Hostname resolution fails. Clients can no longer translate `app.team2.test` to an IP address. However, direct IP access still works (`curl https://10.7.9.236:8443/...`), though this triggers a TLS certificate mismatch since the certificate is issued for `app.team2.test`.

---

## TCP

### Q: Explain the TCP three-way handshake.

1. **SYN:** The client sends a TCP segment with the SYN flag set, proposing an initial sequence number.
2. **SYN-ACK:** The server responds with SYN and ACK flags, acknowledging the client's sequence number and proposing its own.
3. **ACK:** The client acknowledges the server's sequence number. The connection is now established.

This occurs before any TLS or HTTP data is exchanged. In our setup, this handshake happens between Mac 1 and Mac 2 on port 8443.

### Q: Why does TCP use a three-way handshake?

To synchronize sequence numbers between both endpoints and confirm that both sides are ready to communicate. It also prevents duplicate connection requests from old segments (protection against replayed SYN packets).

---

## TLS / HTTPS

### Q: Walk through the TLS handshake.

1. **ClientHello:** Client sends supported TLS versions, cipher suites, and a random value.
2. **ServerHello:** Server selects a TLS version and cipher suite, sends its random value.
3. **Certificate:** Server sends its X.509 certificate (for `app.team2.test`).
4. **ServerKeyExchange:** Server sends parameters for key exchange (e.g., Diffie-Hellman parameters).
5. **ClientKeyExchange:** Client sends its key exchange data.
6. **ChangeCipherSpec + Finished:** Both sides switch to encrypted communication and verify the handshake.

After this, all HTTP data is encrypted inside the TLS tunnel.

### Q: Where does TLS terminate in your architecture?

TLS terminates at nginx on Mac 2. The connection from Mac 1 (client) to Mac 2 (nginx) is encrypted. The connection from Mac 2 (nginx) to Mac 3 (backends) is plain HTTP — this is called "TLS termination at the reverse proxy." This is acceptable because nginx and the backends are on a trusted private LAN.

### Q: Why not use `curl -k` / `--insecure`?

`curl -k` skips certificate validation, which defeats the purpose of TLS. In a real system, this would make the connection vulnerable to man-in-the-middle attacks. Instead, we install our private CA certificate as trusted on the client so that proper certificate chain validation works.

### Q: What is a Certificate Authority (CA)?

A CA is a trusted entity that issues digital certificates. In our setup, we created our own private CA to sign the server certificate for `app.team2.test`. By trusting this CA on the client machine, the client can verify the server's certificate without relying on a public CA.

---

## nginx / Reverse Proxy / Load Balancing

### Q: What is a reverse proxy?

A reverse proxy sits in front of backend servers and forwards client requests to them. The client communicates with the proxy, not the backends directly. In our setup, nginx receives HTTPS requests and forwards them to Backend A or B over plain HTTP.

### Q: How does round-robin load balancing work?

nginx distributes requests across the backend pool in sequential order. The first request goes to Backend A (port 3001), the second to Backend B (port 3002), the third back to A, and so on. This is nginx's default behavior when no specific balancing algorithm is configured.

### Q: How do you prove load balancing is working?

Each backend includes an `X-Backend` response header (`A` or `B`). By sending multiple consecutive requests and inspecting this header, we can observe the round-robin pattern.

### Q: What happens when one backend goes down?

nginx detects the failure and routes all subsequent requests to the surviving backend. When the failed backend comes back online, nginx resumes distributing requests to it.

---

## HTTP Caching

### Q: How does HTTP caching work in your application?

The `/api/status` endpoint returns two caching-related headers:
- **`Cache-Control: public, max-age=30`** — indicates the response can be cached for 30 seconds.
- **`ETag`** — a hash of the response body, used for cache validation.

### Q: What is a conditional request?

When a client has a cached response with an ETag, it can send a new request with the `If-None-Match` header containing that ETag. If the resource hasn't changed (the ETag matches), the server responds with `304 Not Modified` instead of resending the full body. This saves bandwidth.

### Q: What is the difference between `Cache-Control` and `ETag`?

`Cache-Control` tells the client *how long* to cache. `ETag` provides a *validation token* so the client can check if its cached copy is still current. They serve complementary purposes: `Cache-Control` for freshness, `ETag` for revalidation.

---

## Wireshark / Packet Analysis

### Q: Why can't you see HTTP content in the client-to-nginx Wireshark capture?

Because TLS encrypts all HTTP data. Wireshark can see the TLS handshake packets (ClientHello, ServerHello, Certificate) but the actual HTTP requests and responses are encrypted as "Application Data." This is the entire point of HTTPS.

### Q: How can you see HTTP content between nginx and backends?

By capturing packets on Mac 2 or Mac 3 and filtering for ports 3001/3002. Since TLS terminates at nginx, the traffic between nginx and backends is plain HTTP and fully visible in Wireshark.

### Q: What OSI layers are visible in a Wireshark capture?

- **Layer 2 (Data Link):** Ethernet/Wi-Fi frames with MAC addresses
- **Layer 3 (Network):** IP packets with source/destination IP addresses
- **Layer 4 (Transport):** TCP segments with port numbers, flags (SYN, ACK)
- **Layer 5-7 (Application):** DNS queries/responses, TLS handshake, HTTP (if unencrypted)

---

## Protocol Stack

### Q: Map each protocol to its OSI layer.

| Protocol        | Layer              | Purpose in Our System              |
| --------------- | ------------------ | ---------------------------------- |
| Ethernet/Wi-Fi  | Link (Layer 2)     | Physical LAN connectivity          |
| IP              | Network (Layer 3)  | Addressing (10.7.x.x)             |
| TCP             | Transport (Layer 4)| Reliable delivery, port multiplexing |
| UDP             | Transport (Layer 4)| DNS queries                        |
| TLS             | Session/Security   | Encryption between client and nginx |
| HTTP            | Application (Layer 7) | Request/response semantics      |
| DNS             | Application (Layer 7) | Name resolution                 |

### Q: What port numbers does your system use?

| Service       | Port  | Protocol | Machine |
| ------------- | ----- | -------- | ------- |
| DNS           | 53    | UDP/TCP  | Mac 1   |
| HTTPS (nginx) | 8443  | TCP      | Mac 2   |
| Backend A     | 3001  | TCP      | Mac 3   |
| Backend B     | 3002  | TCP      | Mac 3   |

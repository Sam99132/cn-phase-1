# Evidence: 06 — Wireshark: DNS

## What to place here

Wireshark screenshots showing DNS traffic between the client and the DNS server.

### Required screenshots

1. **DNS query and response:**
   Wireshark capture filtered by:
   ```
   dns
   ```
   or:
   ```
   udp.port == 53
   ```
   Screenshot should show:
   - A DNS **query** packet from the client (Mac 1: 10.7.17.112) asking for `app.team2.test`
   - A DNS **response** packet from the DNS server (10.7.17.112, since DNS runs on Mac 1 itself) containing the answer `10.7.9.236`

2. **Packet details (expanded):**
   Expand one DNS response packet to show:
   - Transaction ID
   - Query: `app.team2.test` type A
   - Answer: `app.team2.test → 10.7.9.236`

### Wireshark filter suggestions

```
dns && ip.addr == 10.7.17.112
```

### What the evaluator is looking for

- DNS resolution uses UDP port 53.
- The query is for our private `.test` domain.
- The response contains the correct IP address (10.7.9.236).
- The DNS server is our local dnsmasq instance, not a public resolver.

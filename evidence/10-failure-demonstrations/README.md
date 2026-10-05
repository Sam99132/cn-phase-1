# Evidence: 10 — Failure Demonstrations

## What to place here

Screenshots demonstrating controlled failure scenarios and the system's behavior when components fail.

### Required screenshots

#### Failure 1 — Backend A goes down

1. Stop Backend A on Mac 3 (kill the node process on port 3001).
2. Send requests through nginx:
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
3. Screenshot showing that all requests now go to Backend B (`X-Backend: B`).
4. Screenshot or note showing nginx's behavior (e.g., 502 errors on the first attempt before nginx detects the failure, then automatic failover).

#### Failure 2 — Backend B goes down

1. Stop Backend B on Mac 3 (kill the node process on port 3002).
2. Keep Backend A running.
3. Send requests through nginx:
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
4. Screenshot showing all requests go to Backend A (`X-Backend: A`).

#### Failure 3 — Both backends go down

1. Stop both Backend A and Backend B.
2. Send a request through nginx:
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
3. Screenshot showing nginx returning a `502 Bad Gateway` error (since no backends are available).

#### Failure 4 — DNS server goes down

1. Stop dnsmasq on Mac 1.
2. Attempt to resolve the hostname:
   ```bash
   dig app.team2.test @10.7.17.112
   ```
3. Screenshot showing the DNS query timing out or failing.
4. Show that using the IP address directly still works:
   ```bash
   curl -v https://10.7.9.236:8443/api/status
   ```
   (This may produce a TLS certificate mismatch warning since the cert is issued for `app.team2.test`, not the IP.)

### What the evaluator is looking for

- The system degrades gracefully when individual components fail.
- nginx handles backend failures by routing to surviving backends.
- When all backends are down, nginx returns an appropriate error (502).
- DNS failure prevents hostname resolution but the underlying network still functions.
- These demonstrations show understanding of system resilience and failure modes.

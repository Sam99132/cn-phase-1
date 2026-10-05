# Evidence: 04 — nginx Load Balancing

## What to place here

Screenshots demonstrating that nginx distributes requests across Backend A and Backend B using round-robin load balancing.

### Required screenshots

1. **Multiple curl requests showing X-Backend alternation:**
   ```bash
   # Run this multiple times in sequence:
   curl -s -D - https://app.team2.test:8443/api/status -o /dev/null | grep X-Backend
   ```
   Or use the provided test script:
   ```bash
   ./scripts/test-load-balancing.sh
   ```
   Screenshot should show `X-Backend` alternating between `A` and `B` across consecutive requests.

2. **Full verbose output for one request through nginx:**
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
   Screenshot showing:
   - Connection to `app.team2.test` port 8443
   - TLS negotiation
   - HTTP response with `X-Backend` header

### What the evaluator is looking for

- Requests go through nginx (port 8443), not directly to backends.
- The `X-Backend` header proves which backend served each request.
- The alternation pattern demonstrates round-robin load balancing.

# Evidence: 02 — DNS Resolution

## What to place here

Screenshots showing that the private DNS server (dnsmasq on Mac 1) correctly resolves `app.team2.test` and `api.team2.test`.

### Required screenshots

1. **`dig app.team2.test`:**
   ```bash
   dig @10.7.17.112 app.team2.test
   ```
   Screenshot showing the ANSWER SECTION with:
   ```
   app.team2.test.    0    IN    A    10.7.9.236
   ```

2. **`dig api.team2.test`:**
   ```bash
   dig @10.7.17.112 api.team2.test
   ```
   Screenshot showing the ANSWER SECTION with:
   ```
   api.team2.test.    0    IN    A    10.7.9.236
   ```

3. **(Optional) `nslookup` alternative:**
   ```bash
   nslookup app.team2.test 10.7.17.112
   ```

### What the evaluator is looking for

- DNS queries are sent to Mac 1 (10.7.17.112) on UDP port 53.
- Both `.test` hostnames resolve to Mac 2 (10.7.9.236).
- The DNS server is dnsmasq running locally, not a public DNS resolver.

# Evidence: 05 — TLS / HTTPS

## What to place here

Screenshots demonstrating that HTTPS works with proper TLS certificate validation (no `curl -k`).

### Required screenshots

1. **Successful HTTPS request without `--insecure`:**
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
   Screenshot should show:
   - `SSL connection using TLSv1.2` or `TLSv1.3`
   - `Server certificate:` details including `CN = app.team2.test`
   - Successful HTTP response (no certificate errors)

2. **Certificate details:**
   ```bash
   openssl s_client -connect app.team2.test:8443 -servername app.team2.test </dev/null
   ```
   Screenshot showing the certificate chain and verification result.

3. **(Optional) Browser showing HTTPS:**
   If you open `https://app.team2.test:8443/` in a browser, a screenshot showing the padlock / certificate info.

### What the evaluator is looking for

- TLS is properly configured on nginx (Mac 2, port 8443).
- The certificate is signed by a private CA and trusted on the client.
- No `--insecure` / `-k` flag is used — the connection validates correctly.
- The certificate's CN or SAN matches `app.team2.test`.

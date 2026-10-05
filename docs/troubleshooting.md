# Troubleshooting Guide

Common issues and their solutions for the Phase 1 setup.

---

## DNS Issues

### `dig app.team2.test` returns NXDOMAIN or no answer

**Cause:** dnsmasq is not running or not configured correctly.

**Fix:**
```bash
# Check if dnsmasq is running on Mac 1
sudo lsof -i :53

# Start dnsmasq
sudo brew services start dnsmasq

# Verify the configuration includes:
# address=/app.team2.test/10.7.9.236
cat /usr/local/etc/dnsmasq.conf | grep team2
```

### `dig` works but `curl` cannot resolve the hostname

**Cause:** The system DNS is not pointing to Mac 1.

**Fix:**
- Set Mac 1's IP (10.7.17.112) as the DNS server in System Settings → Network → Wi-Fi → DNS.
- Or use `dig @10.7.17.112` to confirm DNS works, then fix the system-level DNS.

---

## nginx Issues

### `curl: (7) Failed to connect to app.team2.test port 8443`

**Cause:** nginx is not running on Mac 2 or is not listening on port 8443.

**Fix:**
```bash
# On Mac 2, check nginx status
sudo lsof -i :8443

# Test nginx configuration
nginx -t

# Start nginx
brew services start nginx
```

### `502 Bad Gateway`

**Cause:** nginx cannot reach any backend in the upstream pool.

**Fix:**
```bash
# Verify backends are running on Mac 3
curl http://10.7.16.15:3001/api/status
curl http://10.7.16.15:3002/api/status

# Check if Mac 3 is reachable
ping 10.7.16.15
```

### nginx configuration test fails

**Fix:**
```bash
nginx -t
# Read the error message carefully.
# Common causes:
# - Missing TLS certificate/key files
# - Syntax errors in nginx.conf
# - Port 8443 already in use
```

---

## TLS / HTTPS Issues

### `curl: (60) SSL certificate problem: unable to get local issuer certificate`

**Cause:** The private CA certificate is not trusted on the client machine.

**Fix:**
```bash
# On Mac 1, trust the CA certificate:
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain ca.crt
```

### `curl: (35) error:... SSL routines`

**Cause:** TLS certificate or key mismatch, or missing certificate files on Mac 2.

**Fix:**
```bash
# On Mac 2, verify certificates exist:
ls -la /usr/local/etc/nginx/ssl/

# Verify the certificate matches the key:
openssl x509 -noout -modulus -in app.team2.test.crt | md5
openssl rsa -noout -modulus -in app.team2.test.key | md5
# Both md5 values should match.
```

### Certificate hostname mismatch

**Cause:** The certificate's CN/SAN does not include `app.team2.test`.

**Fix:**
Regenerate the certificate with the correct SAN. See `config/tls/README.md`.

---

## Backend Issues

### `Error: listen EADDRINUSE :::3001`

**Cause:** Another process is already using port 3001 (or 3002).

**Fix:**
```bash
# Find the process using the port
lsof -i :3001

# Kill it
kill <PID>

# Restart the backend
node backend/backend-a/server.js
```

### Backend not reachable from other Macs

**Cause:** The backend is bound to `localhost` instead of `0.0.0.0`, or macOS firewall is blocking.

**Fix:**
- The backend code binds to `0.0.0.0` by default.
- Check macOS firewall: System Settings → Network → Firewall. Allow incoming connections for Node.js.

---

## Wireshark Issues

### No packets captured

**Cause:** Capturing on the wrong interface.

**Fix:**
- Select the correct Wi-Fi interface (usually `en0`) in Wireshark.
- Make sure the capture is started before running `curl`.

### Cannot see HTTP content (all encrypted)

**Expected behavior.** HTTP traffic between the client and nginx is encrypted because TLS terminates at nginx. To see unencrypted HTTP traffic between nginx and backends, capture on Mac 2 or Mac 3 and filter for ports 3001/3002.

---

## General Network Issues

### Machines cannot ping each other

**Fix:**
1. Verify all Macs are on the same Wi-Fi network.
2. Check macOS firewall settings.
3. Verify IP addresses: `ifconfig en0 | grep inet`.
4. If IPs have changed (DHCP), update all configurations accordingly.

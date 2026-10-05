# Evidence: 08 — Wireshark: TLS Handshake

## What to place here

Wireshark screenshots showing the TLS handshake and encrypted application data.

### Required screenshots

1. **TLS handshake packets:**
   Wireshark capture filtered by:
   ```
   tls && ip.addr == 10.7.9.236
   ```
   or:
   ```
   ssl && ip.addr == 10.7.9.236
   ```
   Screenshot should show the TLS handshake sequence:

   | # | Source        | Destination   | Info                   |
   |---|---------------|---------------|------------------------|
   | 1 | 10.7.17.112   | 10.7.9.236    | Client Hello           |
   | 2 | 10.7.9.236    | 10.7.17.112   | Server Hello           |
   | 3 | 10.7.9.236    | 10.7.17.112   | Certificate            |
   | 4 | 10.7.9.236    | 10.7.17.112   | Server Key Exchange    |
   | 5 | 10.7.17.112   | 10.7.9.236    | Client Key Exchange    |
   | 6 | Both          | Both          | Change Cipher Spec     |
   | 7 | Both          | Both          | Application Data       |

   > Note: With TLS 1.3, some of these messages are combined. The exact packet sequence depends on the negotiated TLS version.

2. **ClientHello details (expanded):**
   Expand a Client Hello packet to show supported cipher suites and TLS version.

3. **Certificate details (expanded):**
   Expand the Certificate packet to show `app.team2.test` in the subject.

4. **Encrypted application data:**
   Screenshot showing `Application Data` packets — proving that HTTP content is encrypted after the handshake.

### nginx-to-backend traffic (bonus)

If captured on Mac 2 or Mac 3, you can also show that traffic between nginx and backends is **unencrypted** HTTP:
```
ip.addr == 10.7.16.15 && (tcp.port == 3001 || tcp.port == 3002)
```
This would show plain HTTP requests/responses, contrasting with the encrypted client-to-nginx traffic.

### What the evaluator is looking for

- The TLS handshake occurs after the TCP handshake and before HTTP data.
- ClientHello and ServerHello are visible.
- The server certificate for `app.team2.test` is exchanged.
- After the handshake, all application data is encrypted (no readable HTTP in the payload).

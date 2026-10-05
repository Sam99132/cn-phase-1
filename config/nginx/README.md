# nginx Configuration

**Machine:** Mac 2 (10.7.9.236)

## Overview

nginx acts as the single public entry point for all client traffic. It performs four roles:

1. **HTTPS listener** — accepts TLS connections on port 8443
2. **TLS termination** — decrypts HTTPS traffic so backends receive plain HTTP
3. **Reverse proxy** — forwards requests to the backend pool
4. **Load balancer** — distributes requests across Backend A and Backend B using round-robin

## Architecture

```
Client (Mac 1)
     │
     │  HTTPS / TCP port 8443
     ▼
┌─────────────────────┐
│   nginx (Mac 2)     │
│   10.7.9.236:8443   │
│   TLS termination   │
└────────┬────────────┘
         │  HTTP (plain)
    ┌────┴────┐
    ▼         ▼
Backend A  Backend B
  :3001      :3002
   (Mac 3 — 10.7.16.15)
```

## Installation (macOS)

```bash
brew install nginx
```

## Deploying the Configuration

1. Copy `nginx.conf` from this repository to the nginx configuration directory:

   ```bash
   # The exact path depends on your Homebrew installation.
   # Typically:
   cp config/nginx/nginx.conf /usr/local/etc/nginx/servers/app.team2.test.conf
   ```

   Alternatively, `include` this file from the main `nginx.conf`:

   ```nginx
   include /path/to/repo/config/nginx/nginx.conf;
   ```

2. Ensure TLS certificate and key are in place (see `config/tls/README.md`).

3. Test the configuration:

   ```bash
   nginx -t
   ```

4. Start or reload nginx:

   ```bash
   # Start
   brew services start nginx

   # Reload after config changes
   nginx -s reload
   ```

## Verifying

From Mac 1 (or any machine with the CA certificate trusted):

```bash
curl -v https://app.team2.test:8443/api/status
```

Repeat several times to observe the `X-Backend` header alternating between `A` and `B`, confirming round-robin load balancing.

## Key Configuration Details

| Directive               | Value                                       | Purpose                            |
| ----------------------- | ------------------------------------------- | ---------------------------------- |
| `listen`                | `8443 ssl`                                  | HTTPS on non-standard port         |
| `server_name`           | `app.team2.test`                            | Private domain                     |
| `upstream backend_pool` | `10.7.16.15:3001`, `10.7.16.15:3002`        | Round-robin backend pool           |
| `proxy_pass`            | `http://backend_pool`                       | Forward to backends over plain HTTP |
| `proxy_pass_header`     | `X-Backend`                                 | Expose backend identity to client  |
| `ssl_protocols`         | `TLSv1.2 TLSv1.3`                          | Modern TLS only                    |

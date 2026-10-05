# Backend B

**Port:** 3002
**Host:** Mac 3 (10.7.16.15)
**Backend ID:** B

## Endpoints

| Method | Path          | Description                          |
| ------ | ------------- | ------------------------------------ |
| GET    | `/`           | HTML landing page identifying Backend B |
| GET    | `/api/status` | JSON status with caching headers     |

## Response Headers

Every response includes:

```
X-Backend: B
```

The `/api/status` endpoint also returns:

```
Cache-Control: public, max-age=30
ETag: "<md5-hash>"
```

These headers enable HTTP caching demonstrations (fresh requests, cache hits, conditional requests, and `304 Not Modified` responses).

## Running

```bash
cd backend/backend-b
node server.js
```

Or use the provided script from the repository root:

```bash
./scripts/start-backend-b.sh
```

Backend B will listen on `0.0.0.0:3002`.

## Verifying

From any machine on the LAN:

```bash
curl http://10.7.16.15:3002/api/status
```

Expected response:

```json
{
  "backend": "B",
  "status": "ok"
}
```

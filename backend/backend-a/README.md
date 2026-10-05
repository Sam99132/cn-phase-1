# Backend A

**Port:** 3001
**Host:** Mac 3 (10.7.16.15)
**Backend ID:** A

## Endpoints

| Method | Path          | Description                          |
| ------ | ------------- | ------------------------------------ |
| GET    | `/`           | HTML landing page identifying Backend A |
| GET    | `/api/status` | JSON status with caching headers     |

## Response Headers

Every response includes:

```
X-Backend: A
```

The `/api/status` endpoint also returns:

```
Cache-Control: public, max-age=30
ETag: "<md5-hash>"
```

These headers enable HTTP caching demonstrations (fresh requests, cache hits, conditional requests, and `304 Not Modified` responses).

## Running

```bash
cd backend/backend-a
node server.js
```

Or use the provided script from the repository root:

```bash
./scripts/start-backend-a.sh
```

Backend A will listen on `0.0.0.0:3001`.

## Verifying

From any machine on the LAN:

```bash
curl http://10.7.16.15:3001/api/status
```

Expected response:

```json
{
  "backend": "A",
  "status": "ok"
}
```

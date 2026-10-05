# Evidence: 09 — HTTP Caching

## What to place here

Screenshots demonstrating HTTP caching behavior using `Cache-Control` and `ETag` headers.

### Required screenshots

1. **First request (fresh, 200 OK):**
   ```bash
   curl -v https://app.team2.test:8443/api/status
   ```
   Screenshot showing:
   - HTTP `200 OK` response
   - `Cache-Control: public, max-age=30` header
   - `ETag: "<hash>"` header

2. **Conditional request (304 Not Modified):**
   Copy the ETag value from the first response, then:
   ```bash
   curl -v -H 'If-None-Match: "<hash>"' https://app.team2.test:8443/api/status
   ```
   Screenshot showing:
   - HTTP `304 Not Modified` response
   - No response body (the backend told the client its cached copy is still valid)

3. **Mismatched / Stale ETag request (200 OK):**
   If the client provides a stale ETag (or when nginx round-robin routes the request to the other backend whose response/ETag differs):
   ```bash
   curl -v -H 'If-None-Match: "\"mismatched-or-old-etag\""' https://app.team2.test:8443/api/status
   ```
   Returns `200 OK` with the new body and updated ETag.

### Caching flow explanation

```
Request 1 (no cache):
  Client → GET /api/status → Backend → 200 OK + ETag + Cache-Control

Request 2 (conditional matching):
  Client → GET /api/status + If-None-Match: "<matching-etag>" → Backend → 304 Not Modified (empty body)

Request 3 (stale / mismatched cache):
  Client → GET /api/status + If-None-Match: "<old-etag>" → Backend → 200 OK + new ETag + full body
```

### Testing Tip for Round-Robin Load Balancing

Since nginx alternates between Backend A and Backend B (round-robin):
- Backend A's status body produces a distinct ETag (e.g. hash of `{"backend":"A","status":"ok"}`).
- Backend B's status body produces a distinct ETag (e.g. hash of `{"backend":"B","status":"ok"}`).
- When testing conditional requests against the VIP (`https://app.team2.test:8443`), either test directly against the backend (e.g., `curl -v -H 'If-None-Match: ...' http://10.7.16.15:3001/api/status`) or send two requests in succession through nginx to observe matching on the same backend or cache invalidation on backend alternation.

### What the evaluator is looking for

- The backend returns `Cache-Control` and `ETag` headers.
- A conditional request with a matching `If-None-Match` header produces `304 Not Modified`.
- This demonstrates HTTP-level caching at the application layer.

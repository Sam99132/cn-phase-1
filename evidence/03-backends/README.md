# Evidence: 03 — Backend Responses

## What to place here

Screenshots showing that both backends respond correctly when accessed directly (bypassing nginx).

### Required screenshots

1. **Backend A response:**
   ```bash
   curl -v http://10.7.16.15:3001/api/status
   ```
   Expected output:
   ```json
   {"backend":"A","status":"ok"}
   ```
   The response headers should include `X-Backend: A`.

2. **Backend B response:**
   ```bash
   curl -v http://10.7.16.15:3002/api/status
   ```
   Expected output:
   ```json
   {"backend":"B","status":"ok"}
   ```
   The response headers should include `X-Backend: B`.

3. **Backend A landing page:**
   ```bash
   curl http://10.7.16.15:3001/
   ```

4. **Backend B landing page:**
   ```bash
   curl http://10.7.16.15:3002/
   ```

### What the evaluator is looking for

- Both backends are running on Mac 3 (10.7.16.15) on separate ports.
- Each backend correctly identifies itself via the `X-Backend` header and the JSON `backend` field.
- The responses demonstrate working HTTP/REST endpoints.

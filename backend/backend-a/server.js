/**
 * Backend A — Computer Networks Phase 1
 *
 * A minimal HTTP server that identifies itself as Backend A.
 * Runs on port 3001 on Mac 3 (10.7.16.15).
 *
 * Endpoints:
 *   GET /            — HTML landing page
 *   GET /api/status  — JSON status with Cache-Control and ETag headers
 */

const http = require("http");
const crypto = require("crypto");

const PORT = 3001;
const BACKEND_ID = "A";

/**
 * Generate an ETag from response body content.
 */
function generateETag(body) {
  return '"' + crypto.createHash("md5").update(body).digest("hex") + '"';
}

const server = http.createServer((req, res) => {
  // ── GET / ──────────────────────────────────────────────────────────
  if (req.method === "GET" && req.url === "/") {
    const html = `<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Backend ${BACKEND_ID}</title></head>
<body>
  <h1>Backend ${BACKEND_ID}</h1>
  <p>Computer Networks — Phase 1</p>
  <p>Host: ${req.headers.host || "unknown"}</p>
</body>
</html>`;

    res.writeHead(200, {
      "Content-Type": "text/html; charset=utf-8",
      "X-Backend": BACKEND_ID,
    });
    res.end(html);
    return;
  }

  // ── GET /api/status ────────────────────────────────────────────────
  if (req.method === "GET" && req.url === "/api/status") {
    const body = JSON.stringify({
      backend: BACKEND_ID,
      status: "ok",
    });

    const etag = generateETag(body);

    // Conditional request: return 304 if ETag matches
    const ifNoneMatch = req.headers["if-none-match"];
    if (ifNoneMatch && (ifNoneMatch === etag || ifNoneMatch === etag.replace(/"/g, ""))) {
      res.writeHead(304, {
        "X-Backend": BACKEND_ID,
        ETag: etag,
        "Cache-Control": "public, max-age=30",
      });
      res.end();
      return;
    }

    res.writeHead(200, {
      "Content-Type": "application/json",
      "X-Backend": BACKEND_ID,
      "Cache-Control": "public, max-age=30",
      ETag: etag,
    });
    res.end(body);
    return;
  }

  // ── 404 ────────────────────────────────────────────────────────────
  res.writeHead(404, {
    "Content-Type": "application/json",
    "X-Backend": BACKEND_ID,
  });
  res.end(JSON.stringify({ error: "Not Found" }));
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend ${BACKEND_ID} listening on 0.0.0.0:${PORT}`);
});

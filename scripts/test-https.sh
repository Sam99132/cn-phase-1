#!/bin/bash
# Test HTTPS connectivity through nginx (Mac 2)
# Run from Mac 1 after DNS and TLS CA are configured.
#
# This script does NOT use -k / --insecure.
# The CA certificate must be trusted on the client machine first.
# See config/tls/README.md for instructions.

ENDPOINT="https://app.team2.test:8443"

echo "=========================================="
echo " HTTPS Test — ${ENDPOINT}"
echo "=========================================="
echo ""

echo "--- GET /api/status (verbose) ---"
curl -v "${ENDPOINT}/api/status" 2>&1
echo ""
echo ""

echo "--- GET / ---"
curl -s "${ENDPOINT}/"
echo ""
echo ""

echo "=========================================="
echo " Check the X-Backend header above to see"
echo " which backend served the request."
echo "=========================================="

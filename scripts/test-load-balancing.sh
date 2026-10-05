#!/bin/bash
# Test round-robin load balancing through nginx
# Sends multiple requests and extracts the X-Backend header to show alternation.
#
# Run from Mac 1 after DNS, TLS CA, and nginx are configured.

ENDPOINT="https://app.team2.test:8443/api/status"
NUM_REQUESTS=10

echo "=========================================="
echo " Load Balancing Test — Round-Robin"
echo " Sending ${NUM_REQUESTS} requests to:"
echo " ${ENDPOINT}"
echo "=========================================="
echo ""

for i in $(seq 1 ${NUM_REQUESTS}); do
  BACKEND=$(curl -s -o /dev/null -w '' -D - "${ENDPOINT}" 2>/dev/null \
    | grep -i "X-Backend" \
    | tr -d '\r')
  echo "Request ${i}: ${BACKEND}"
done

echo ""
echo "=========================================="
echo " If load balancing is working, you should"
echo " see X-Backend alternating between A and B."
echo "=========================================="

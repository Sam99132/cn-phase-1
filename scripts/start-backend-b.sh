#!/bin/bash
# Start Backend B on Mac 3 (10.7.16.15:3002)
echo "Starting Backend B on port 3002..."
cd "$(dirname "$0")/../backend/backend-b" || exit 1
node server.js

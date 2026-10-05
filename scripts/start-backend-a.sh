#!/bin/bash
# Start Backend A on Mac 3 (10.7.16.15:3001)
echo "Starting Backend A on port 3001..."
cd "$(dirname "$0")/../backend/backend-a" || exit 1
node server.js

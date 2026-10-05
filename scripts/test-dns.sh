#!/bin/bash
# Test DNS resolution from Mac 1 (10.7.17.112)
# Queries the local dnsmasq server for app.team2.test and api.team2.test

DNS_SERVER="10.7.17.112"

echo "=========================================="
echo " DNS Resolution Test"
echo "=========================================="
echo ""

echo "--- dig app.team2.test @${DNS_SERVER} ---"
dig +short app.team2.test @${DNS_SERVER}
echo ""

echo "--- dig api.team2.test @${DNS_SERVER} ---"
dig +short api.team2.test @${DNS_SERVER}
echo ""

echo "--- Full query for app.team2.test ---"
dig app.team2.test @${DNS_SERVER}
echo ""

echo "=========================================="
echo " Expected: app.team2.test → 10.7.9.236"
echo " Expected: api.team2.test → 10.7.9.236"
echo "=========================================="

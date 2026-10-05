# Evidence: 01 — LAN Connectivity

## What to place here

Screenshots showing successful ping between all three Macs on the private LAN.

### Required screenshots

1. **Mac 1 → Mac 2:**
   ```bash
   ping -c 4 10.7.9.236
   ```
   Screenshot showing successful replies.

2. **Mac 1 → Mac 3:**
   ```bash
   ping -c 4 10.7.16.15
   ```
   Screenshot showing successful replies.

3. **Mac 2 → Mac 3:**
   ```bash
   ping -c 4 10.7.16.15
   ```
   Screenshot showing successful replies.

4. **(Optional) Mac 2 → Mac 1:**
   ```bash
   ping -c 4 10.7.17.112
   ```

### What the evaluator is looking for

- All three machines are on the same private LAN / Wi-Fi.
- Pings succeed with reasonable round-trip times.
- No packet loss.

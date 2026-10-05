# Evidence: 07 — Wireshark: TCP Three-Way Handshake

## What to place here

Wireshark screenshots showing the TCP three-way handshake for the HTTPS connection to nginx.

### Required screenshots

1. **TCP handshake packets:**
   Wireshark capture filtered by:
   ```
   tcp.port == 8443 && tcp.flags.syn == 1
   ```
   or more broadly:
   ```
   ip.addr == 10.7.9.236 && tcp.port == 8443
   ```
   Screenshot should show three consecutive packets:

   | # | Source        | Destination   | Info           |
   |---|---------------|---------------|----------------|
   | 1 | 10.7.17.112   | 10.7.9.236    | SYN            |
   | 2 | 10.7.9.236    | 10.7.17.112   | SYN-ACK        |
   | 3 | 10.7.17.112   | 10.7.9.236    | ACK            |

2. **Packet details (expanded):**
   Expand one SYN packet to show TCP flags, sequence numbers, and destination port 8443.

### What the evaluator is looking for

- The TCP three-way handshake occurs before any TLS or HTTP data.
- The client (Mac 1) initiates the connection to nginx (Mac 2) on port 8443.
- The SYN → SYN-ACK → ACK sequence is clearly visible.
- This demonstrates Transport Layer (Layer 4) behavior.

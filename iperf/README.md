
# iperf3 Performance Testing over FASP

This demo shows how to run iperf3 TCP performance tests through IBM Aspera's FASP protocol using faspio-gateway containers. The setup creates a tunnel that converts TCP traffic to FASP for high-performance data transfer, then converts it back to TCP.

## Architecture

- **iperf-client**: Runs iperf3 client tests  
- **gateway1**: Converts incoming TCP to FASP
- **gateway2**: Converts FASP back to TCP
- **iperf-server**: Runs iperf3 server

Traffic flow: `iperf-client` → `gateway1` (TCP→FASP) → `gateway2` (FASP→TCP) → `iperf-server`

## Prerequisites

- Docker and Docker Compose installed
- Access to IBM Aspera faspio-gateway container images

## One-Command Demo

### FASP Tunnel Mode (Default)
```bash
./run-test.sh
```
Runs iperf3 TCP performance test through the FASP tunnel.

### Direct Mode (Concept Validation) 
```bash
./run-test.sh --direct
```
Runs iperf3 TCP performance test via direct connection, bypassing the gateways.

## Testing Modes

- **FASP Tunnel**: Traffic goes through both gateways with FASP protocol conversion
- **Direct**: Traffic goes directly to the server, useful for concept validation and troubleshooting

Note: Performance differences between modes may not be visible in Docker localhost environments. This demo is primarily for concept validation and architecture understanding.

## What You'll See

The demo downloads 100MB of data and shows:
- Bidirectional TCP performance measurements
- Connection establishment through the tunnel
- Detailed logs in the `./logs/` directory

## Logs

Log files are automatically generated in `./logs/`:
- `iperf-client.log` / `iperf-client_err.log` - Client test results
- `iperf-server.log` / `iperf-server_err.log` - Server activity  
- `gateway1.log` / `gateway1_err.log` - First gateway logs
- `gateway2.log` / `gateway2_err.log` - Second gateway logs

## Manual Docker Commands

If you prefer manual control:

```bash
# FASP tunnel mode
docker compose up --build --abort-on-container-exit

# Direct mode
IPERF_HOST=iperf-server docker compose up --build --abort-on-container-exit iperf-client iperf-server

# Clean up
docker compose down --volumes --remove-orphans
```

# FTP Tunneling over FASP - Demo

**🚀 Quick Demo**: Tunnel FTP traffic over FASP protocol using faspio Gateway

This complete example shows how to tunnel FTP connections through FASP for improved performance and reliability over long distances and unreliable networks.

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- **Aspera Trial License**: A valid `aspera-license` file is required for the server-side gateway (gw2)

### One-Command Demo
```bash
./run-test.sh              # Test with FASP tunnel (default 10MB)
./run-test.sh 50           # Test with FASP tunnel (50MB file)
./run-test.sh --direct     # Test direct FTP (bypass tunnel, 10MB)
./run-test.sh --direct 1   # Test direct FTP (bypass tunnel, 1MB)
```

**Or run manually:**
```bash
docker compose up --build --abort-on-container-exit
```

### What It Does
1. ✅ Validates FTP-over-FASP tunneling concept and setup
2. ✅ Verifies file integrity end-to-end through tunnel
3. ✅ Provides troubleshooting comparison (direct vs tunneled)

## Architecture

```
FTP Client → [GW1] → FASP Network → [GW2] → FTP Server
    |          ↑                        ↑         |
Port 21-22   TCP→FASP                FASP→TCP  Port 21-22
```

**Components:**
- **GW1** (Client Gateway): Converts TCP FTP → FASP tunnel
- **GW2** (Server Gateway): Converts FASP tunnel → TCP FTP
- **FTP Server**: Standard vsftpd server with test files
- **Test Client**: Automated verification client

## Configuration

| Component | Purpose | Key Settings |
|-----------|---------|-------------|
| GW1 | Client-side gateway | TCP:21-22→FASP (ports 21-22) |
| GW2 | Server-side gateway | FASP→TCP:21-22 (ports 21-22) |
| FTP Server | Test target | Passive mode, port 22 only |

## Testing Modes

### FASP Tunnel Mode (Default)
Tests the complete gateway setup with FTP traffic flowing through FASP tunnel.
```bash
./run-test.sh           # 10MB through FASP tunnel
./run-test.sh 100       # 100MB through FASP tunnel
```

### Direct FTP Mode (No Tunnel)
Bypasses gateways for troubleshooting - validates basic FTP functionality.
```bash
./run-test.sh --direct      # 10MB via direct FTP
./run-test.sh --direct 5    # 5MB via direct FTP (faster test)
```

> **Note**: Performance differences aren't visible in Docker localhost. Real FASP benefits appear over WAN with latency/packet loss.

## Customization

**Change FTP credentials:**
```bash
FTP_USER=testuser FTP_PASS=mypassword ./run-test.sh
```

**Manual Docker Compose:**
```bash
FILE_SIZE_MB=50 docker compose up --build --abort-on-container-exit
```

## Troubleshooting

### Common Issues

**❌ "FASP server not enabled in license"**
- Solution: You need to obtain a valid `aspera-license` file and place it in the `gw2/` directory
- See "Obtaining Aspera License" section below for details
- **Troubleshooting**: Use `./run-test.sh --direct` to isolate FTP issues from gateway issues

### Success Indicators
```
✅ [client] test succeeded: downloaded file matches the original
✅ client-1 exited with code 0
```

### Getting Help
- Check container logs: `docker compose logs [service]`
- Verify network connectivity: `docker compose ps`
- Clean restart: `docker compose down -v && docker compose up --build`

## Files Structure
```
tests/e2e/ftp-tunneling/
├── run-test.sh          # 🚀 One-command demo runner
├── compose.yaml         # Docker services configuration
├── gw1/gateway.toml     # Client gateway config
├── gw2/
│   ├── gateway.toml     # Server gateway config
│   └── aspera-license   # FASP server license (required)
├── client/              # Test automation
└── server/              # FTP server setup
```

## Obtaining Aspera License

**⚠️ IMPORTANT**: This demo requires a valid IBM Aspera trial license to function properly.

### Getting a Trial License

1. **Email IBM Aspera Licensing Team**: Send your request to `aspera-licenses@wwpdl.vnet.ibm.com`

2. **Include Required Information**:
   - Site ID (if you have one)
   - Company name and address
   - Phone number
   - Primary contact email address
   - Request: "30-day evaluation license for IBM Aspera faspio Gateway"

3. **Response Time**: Expect to receive your license file within 24 hours if approved

4. **Installation**: Place the received `aspera-license` file in the `gw2/` directory

### Alternative Contact
For additional assistance with IBM Aspera licensing, you can contact:
- **IBM Aspera Support Partners**: Various IBM partners can assist with trial-to-full license upgrades

### License File Requirements
- License filename format: `faspioGateway-*.eval.aspera-license`
- Must be placed in `gw2/aspera-license` (exact path as shown in docker-compose.yaml)
- Required for FASP server functionality in gateway

## Next Steps

After running this demo:

1. **Validate setup** using both `./run-test.sh` and `./run-test.sh --direct` 
2. **Deploy to real networks** where FASP performance benefits are measurable
3. **Modify configurations** in `gw1/` and `gw2/` directories for your environment
4. **Test with your own FTP server** by updating server settings

---
💡 **Tip**: This demo works entirely within Docker - no host FTP setup required!

#!/bin/bash
#
# FTP Tunneling Test Runner
# Simple script to run the FTP over FASP tunneling demo
#
# Usage: ./run-test.sh [OPTIONS] [file_size_mb]
# Examples: 
#   ./run-test.sh               (downloads 10MB file through FASP tunnel)
#   ./run-test.sh 50            (downloads 50MB file through FASP tunnel)
#   ./run-test.sh --direct      (downloads 10MB file via direct FTP, no tunnel)
#   ./run-test.sh --direct 1    (downloads 1MB file via direct FTP)
# Default: 10MB through FASP tunnel

set -e

# Parse command line arguments
DIRECT_MODE=false
FILE_SIZE_MB=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --direct)
      DIRECT_MODE=true
      shift
      ;;
    [0-9]*)
      FILE_SIZE_MB="$1"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--direct] [file_size_mb]"
      exit 1
      ;;
  esac
done

# Set default file size
FILE_SIZE_MB="${FILE_SIZE_MB:-10}"

if [ "$DIRECT_MODE" = true ]; then
  echo "🧪 Starting Direct FTP Test (bypassing gateways)..."
  echo "📋 This will download a ${FILE_SIZE_MB}MB file via direct FTP connection"
  export FTP_HOST=server
  SERVICES="client server"
else
  echo "🚀 Starting FTP Tunneling Demo..."
  echo "📋 This will download a ${FILE_SIZE_MB}MB file through a FASP tunnel"
  SERVICES=""
fi
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Clean up any previous runs
echo "🧹 Cleaning up previous test runs..."
docker compose down --remove-orphans --volumes 2>/dev/null || true

# Run the test
if [ "$DIRECT_MODE" = true ]; then
  echo "▶️  Running direct FTP test..."
else
  echo "▶️  Running FTP tunneling test..."
fi
echo "   This should complete in 30 seconds or less..."
echo ""

if FILE_SIZE_MB="$FILE_SIZE_MB" timeout 30 docker compose up --build --abort-on-container-exit $SERVICES; then
    echo ""
    if [ "$DIRECT_MODE" = true ]; then
      echo "✅ SUCCESS: Direct FTP test completed successfully!"
      echo "   - ${FILE_SIZE_MB}MB file was downloaded via direct FTP connection"
    else
      echo "✅ SUCCESS: FTP tunneling test completed successfully!"
      echo "   - ${FILE_SIZE_MB}MB file was downloaded through the FASP tunnel"
    fi
    echo "   - File integrity verification passed"
else
    echo ""
    if [ "$DIRECT_MODE" = true ]; then
      echo "❌ FAILED: Direct FTP test failed or timed out"
    else
      echo "❌ FAILED: FTP tunneling test failed or timed out"
    fi
    echo "   Check the logs above for details"
    exit 1
fi

# Clean up
echo ""
echo "🧹 Cleaning up containers..."
docker compose down --volumes --remove-orphans

echo "✨ Demo complete!"

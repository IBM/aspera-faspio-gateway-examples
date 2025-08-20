#!/bin/bash
#
# iperf3 Performance Test Runner
# Simple script to run iperf3 TCP performance tests with optional FASP tunneling
#
# Usage: ./run-test.sh [OPTIONS]
# Examples: 
#   ./run-test.sh         (runs TCP test through FASP tunnel)
#   ./run-test.sh --direct (runs TCP test via direct connection, no tunnel)
# Default: TCP through FASP tunnel

set -e

# Cleanup function for signal handling
cleanup() {
    echo ""
    echo "🛑 Interrupted! Cleaning up containers..."
    docker compose down --volumes --remove-orphans || true
    exit 1
}

# Set up signal handlers
trap cleanup INT TERM

# Parse command line arguments
DIRECT_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --direct)
      DIRECT_MODE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--direct]"
      exit 1
      ;;
  esac
done

if [ "$DIRECT_MODE" = true ]; then
  echo "🧪 Starting Direct iperf3 Test (bypassing gateways)..."
  echo "📋 This will run a TCP performance test via direct connection"
  export IPERF_HOST=iperf-server
else
  echo "🚀 Starting iperf3 FASP Tunneling Demo..."
  echo "📋 This will run a TCP performance test through FASP tunnel"
fi
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Clean up any previous runs
echo "🧹 Cleaning up previous test runs..."
docker compose down --remove-orphans --volumes || true

# Run the test
if [ "$DIRECT_MODE" = true ]; then
  echo "▶️  Running direct iperf3 TCP test..."
else
  echo "▶️  Running iperf3 TCP tunneling test..."
fi
echo "   This should complete in 30 seconds or less..."
echo ""

if [ "$DIRECT_MODE" = true ]; then
  # Direct mode: start server first, then run client
  echo "Starting iperf server..."
  docker compose up --build -d iperf-server
  sleep 5
  echo "Running iperf client..."
  timeout 45 docker compose run --rm iperf-client
else
  # FASP tunnel mode: start services in sequence for proper startup
  echo "Starting infrastructure services..."
  docker compose up --build -d iperf-server gateway2 gateway1
  
  echo "Waiting for services to be ready..."
  sleep 10
  
  echo "Starting client test..."
  docker compose run --rm iperf-client
fi

# Store exit code and check result
COMPOSE_EXIT=$?
if [ $COMPOSE_EXIT -eq 0 ]; then
    echo ""
    if [ "$DIRECT_MODE" = true ]; then
      echo "✅ SUCCESS: Direct iperf3 TCP test completed successfully!"
      echo "   - Performance test completed via direct connection"
    else
      echo "✅ SUCCESS: iperf3 TCP tunneling test completed successfully!"
      echo "   - Performance test completed through the FASP tunnel"
    fi
    echo "   - Check logs in ./logs/ directory for detailed results"
else
    echo ""
    if [ "$DIRECT_MODE" = true ]; then
      echo "❌ FAILED: Direct iperf3 TCP test failed or timed out"
    else
      echo "❌ FAILED: iperf3 TCP tunneling test failed or timed out"
    fi
    echo "   Check the logs above for details"
    exit 1
fi

# Clean up
echo ""
echo "🧹 Cleaning up containers..."
docker compose down --volumes --remove-orphans || true

echo "✨ Demo complete!"

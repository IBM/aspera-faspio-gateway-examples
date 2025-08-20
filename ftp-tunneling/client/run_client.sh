#!/bin/sh
#
# Entry point for the test client.  This script performs three tasks:
#   1. It generates test data (1 MB, 10 MB and 100 MB random files)
#      inside a shared data volume mounted at /data/$FTP_USER.  If the
#      files already exist they are left untouched so repeated runs do
#      not regenerate them unnecessarily.
#   2. It waits for the gw1 gateway to accept FTP connections.  It
#      attempts to list the root directory every few seconds until
#      successful.
#   3. It downloads the 100 MB file through the gateway, verifies the
#      downloaded file matches the original on disk and prints a
#      success message.  If any step fails the script exits with a
#      non‑zero status code.

set -euo pipefail

# Use environment variables with sensible defaults.  These must match the
# credentials configured for the vsftpd server.
FTP_USER="${FTP_USER:-myuser}"
FTP_PASS="${FTP_PASS:-mypass}"
FTP_HOST="${FTP_HOST:-gw1}"
FTP_PORT="${FTP_PORT:-21}"
FILE_SIZE_MB="${FILE_SIZE_MB:-10}"

# Directory inside the shared volume where the server stores user files.
DATA_DIR="/data/${FTP_USER}"

# Set up logging
LOG_FILE="/var/log/client.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages to both stdout and log file
log() {
    echo "$@" | tee -a "$LOG_FILE"
}

log "[client] starting test – user: $FTP_USER, host: $FTP_HOST, port: $FTP_PORT, file size: ${FILE_SIZE_MB}MB"

# Generate random test files if they do not already exist.  Use dd with
# bs=1 MiB to create files of exact size.  The random data is not
# compressible which better exercises the data path.
mkdir -p "$DATA_DIR"

generate_file() {
  local filename="$1"
  local count="$2"
  local filepath="$DATA_DIR/$filename"
  if [ ! -f "$filepath" ]; then
    log "[client] generating $filename (${count} MiB) in $DATA_DIR"
    dd if=/dev/urandom of="$filepath" bs=1048576 count="$count" status=none
  else
    log "[client] $filename already exists, skipping generation"
  fi
}

TEST_FILE="${FILE_SIZE_MB}MB"
TEST_FILE_PATH="$DATA_DIR/$TEST_FILE"

if [ ! -f "$TEST_FILE_PATH" ]; then
    log "[client] generating $TEST_FILE (${FILE_SIZE_MB} MiB) in $DATA_DIR"
    dd if=/dev/urandom of="$TEST_FILE_PATH" bs=1048576 count="$FILE_SIZE_MB" status=none
else
    log "[client] $TEST_FILE already exists, skipping generation"
fi

# Wait for the gateway to accept FTP connections.  We attempt to run an
# lftp command that lists the remote directory.  If it fails we sleep
# for a short period and retry.  Time out after 60 seconds (30 attempts).
log "[client] waiting for $FTP_HOST to become available..."
ATTEMPTS=0
until lftp -u "$FTP_USER","$FTP_PASS" -e "cls -1; bye" "$FTP_HOST":"$FTP_PORT" >/dev/null 2>&1; do
  ATTEMPTS=$((ATTEMPTS + 1))
  if [ "$ATTEMPTS" -gt 30 ]; then
    log "[client] timeout waiting for FTP service on $FTP_HOST:$FTP_PORT"
    exit 1
  fi
  sleep 2
done
log "[client] $FTP_HOST is accepting connections"

# Download the 100 MB file into a temporary directory.  We remove any
# pre‑existing copy to ensure the download actually happens.
WORKDIR="/tmp/ftp_test"
mkdir -p "$WORKDIR"
rm -f "$WORKDIR/$TEST_FILE"

log "[client] downloading $TEST_FILE file via gateway"
lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST":"$FTP_PORT" \
  -e "get $TEST_FILE -o $WORKDIR/$TEST_FILE; bye"

log "[client] verifying integrity of downloaded file"
if cmp -s "$WORKDIR/$TEST_FILE" "$TEST_FILE_PATH"; then
  log "[client] test succeeded: downloaded file matches the original"
else
  log "[client] test FAILED: downloaded file does not match"
  exit 1
fi

# Success
exit 0

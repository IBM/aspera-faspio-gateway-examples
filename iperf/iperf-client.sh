#!/bin/sh

# Default values
BYTES_TO_SEND=100M
NB_OF_SESSIONS=1

# Set common variables
IPERF_HOST="${IPERF_HOST:-gateway1}"
base_command="/usr/local/bin/iperf3 --client ${IPERF_HOST} -V --bytes ${BYTES_TO_SEND} --connect-timeout 10000"
options="--bidir -P ${NB_OF_SESSIONS}"
log_output="> >(tee /tmp/logs/iperf-client.log) 2> >(tee /tmp/logs/iperf-client_err.log >&2)"

# Run the final command with options
eval "${base_command} ${options} ${log_output}"

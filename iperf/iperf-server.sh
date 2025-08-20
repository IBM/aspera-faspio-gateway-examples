#!/bin/sh

echo "Starting iperf server"
/usr/local/bin/iperf3 -s -V > >(tee /tmp/logs/iperf-server.log) 2> >(tee /tmp/logs/iperf-server_err.log >&2)

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5 AS builder

# Pin iperf3 version for security and stability
ARG IPERF_VERSION=3.19.1
ARG IPERF_SHA256=85e480d7fffdcb1368888aaee9d76bcfc211e17c2a6dcb2060b281498f82c97b

# Add iperf source with checksum verification
ADD https://github.com/esnet/iperf/archive/${IPERF_VERSION}.tar.gz /tmp/iperf.tar.gz

# Build iperf3 in a single layer to minimize image size
RUN set -ex && \
    # Verify download integrity
    echo "${IPERF_SHA256}  /tmp/iperf.tar.gz" | sha256sum -c - && \
    # Install build dependencies
    microdnf update -y && \
    microdnf install -y tar gzip make gcc && \
    # Extract and build iperf3
    cd /tmp && \
    tar xzf iperf.tar.gz && \
    cd iperf-${IPERF_VERSION} && \
    ./configure \
        --disable-profiling && \
    make --jobs="$(nproc)" && \
    make install && \
    # Verify installation
    /usr/local/bin/iperf3 --version && \
    # Clean up build artifacts and cache
    cd / && \
    rm -rf /tmp/iperf* && \
    microdnf clean all

# Production image with minimal footprint
FROM registry.access.redhat.com/ubi9/ubi-micro:9.5

# Copy only the iperf3 binary and required libraries
COPY --from=builder /usr/local/bin/iperf3 /usr/local/bin/iperf3
COPY --from=builder /usr/local/lib/libiperf.* /usr/local/lib/

# Create non-root user for security
RUN echo "iperf:x:1001:1001:iperf user:/:/sbin/nologin" >> /etc/passwd && \
    echo "iperf:x:1001:" >> /etc/group

# Set library path for dynamic linking
ENV LD_LIBRARY_PATH=/usr/local/lib

# Security: Run as non-root user
USER iperf

# Health check to verify iperf3 is working
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/iperf3 --version >/dev/null || exit 1

# Default to server mode
ENTRYPOINT ["/usr/local/bin/iperf3"]
CMD ["--server", "--verbose"]

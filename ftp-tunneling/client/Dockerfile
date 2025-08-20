#
# Client container for the faspio Gateway FTP tunnelling test.
#
# This image installs a minimal FTP client (lftp) on Alpine Linux.  It
# copies in a small script that generates random test data, connects to the
# gw1 gateway, downloads a file and verifies its integrity.  See
# run_client.sh for details.  The entrypoint is kept simple: the script
# runs on container start and the container exits with the appropriate
# exit code.

FROM alpine:3.18

# Install lftp for FTP interactions and core utilities such as dd and cmp.
RUN apk add --no-cache lftp coreutils

# Copy the client script and lftp configuration into the image.
COPY run_client.sh /usr/local/bin/run_client.sh
RUN chmod +x /usr/local/bin/run_client.sh

WORKDIR /client

# The client script is the default entrypoint.  It will generate data,
# perform the test and exit with status 0 on success.
ENTRYPOINT ["/usr/local/bin/run_client.sh"]

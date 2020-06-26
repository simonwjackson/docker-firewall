FROM alpine:edge

# Install runtime dependencies. The versions are pinned for stable,
# reproducible, deterministic, pure builds.
#
# netcat-openbsd is needed because busybox's nc doesn't support the `-k` flag
# which allows for accepting clients after the first one disconnects.
RUN apk --update add \
  iptables \
  ip6tables \
  netcat-openbsd

# This is only address, port and protocol traffic will be allowed to be sent to
# (besides the docker internal network).
ENV ALLOW_ADDRESSES=
ENV ALLOW_PORTS=

# One of udp or tcp.
ENV ALLOW_PROTO udp

# This port will be open and accepting TCP connections after the firewall has
# been initialized. Only one client can connect to this port at a time so
# clients SHOULD not hold open connections and only keep the connection open
# long enough to check whether it is active. A script like
# [wait-for](https://github.com/Eficode/wait-for) can be used to consume this
# event.
ENV FIREWALL_READY_SIGNAL_PORT 60000

# Setting up the firewall, can only be done at container start time.
COPY ./setup_firewall.sh /firewall/
ENTRYPOINT [ "/firewall/setup_firewall.sh" ]

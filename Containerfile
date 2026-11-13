# Noctora OS - the living-room OS
# Fedora Atomic (bootc) image built on Universal Blue's Kinoite base,
# which already includes the full multimedia codec set and hardware video decoding.

ARG FEDORA_VERSION=45
FROM ghcr.io/ublue-os/kinoite-main:${FEDORA_VERSION}

ARG NOCTORA_VERSION=1.0
ARG NOCTORA_CODENAME=Afterdark

# Config files, services, scripts and branding go straight into the image root.
COPY system_files/ /

# One-shot build script (removed after it runs).
COPY build_files/ /tmp/build/

RUN NOCTORA_VERSION="${NOCTORA_VERSION}" \
    NOCTORA_CODENAME="${NOCTORA_CODENAME}" \
    bash /tmp/build/build.sh && \
    rm -rf /tmp/build

# Catch common bootc image mistakes at build time.
RUN bootc container lint

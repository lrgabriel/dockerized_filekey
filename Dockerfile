# syntax=docker/dockerfile:1.6

# ============================================================
# Stage 1: Clone the upstream FileKey repository
# ============================================================
# Pinned to alpine:3.19 for reproducible builds
FROM alpine:3.19@sha256:6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0 AS builder

# Install git (minimal footprint)
RUN apk add --no-cache git=2.43.4-r0

# Pinned upstream FileKey commit for reproducibility.
# Update FILEKEY_REF to the desired tag or commit SHA when upgrading.
ARG FILEKEY_REPO=https://github.com/nicholaswilde/filekey.git
ARG FILEKEY_REF=main

WORKDIR /src

RUN git clone --depth 1 --branch "${FILEKEY_REF}" "${FILEKEY_REPO}" . \
    && rm -rf .git

# ============================================================
# Stage 2: Lightweight nginx-alpine runtime
# ============================================================
# Pinned to nginx:1.26.2-alpine for reproducible builds
FROM nginx:1.26.2-alpine@sha256:2140dad235c130ac861018a4e13a6bc8aea3a35f3a40e20c1b060d51a7efd250 AS runtime

# Drop all capabilities; run as non-root user
# nginx default is to run workers as 'nginx' user (uid 101)
RUN rm /etc/nginx/conf.d/default.conf

# Copy static PWA files from the builder stage
COPY --from=builder /src /usr/share/nginx/html

# Custom minimal nginx config: serve on port 8080 as non-root
COPY nginx.conf /etc/nginx/conf.d/filekey.conf

# Ensure the nginx cache/pid directories are writable by the nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/ || exit 1

LABEL org.opencontainers.image.title="dockerized_filekey" \
      org.opencontainers.image.description="FileKey PWA served via nginx-alpine" \
      org.opencontainers.image.source="https://github.com/lrgabriel/dockerized_filekey" \
      org.opencontainers.image.licenses="MIT"

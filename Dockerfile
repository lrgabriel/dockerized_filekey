# Stage 1: Clone the FileKey repository
# alpine:3.23.3
FROM alpine@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659 AS build

RUN apk add --no-cache git

# Pin to a specific, verified commit (see VERSION_PINS.md)
RUN git init /filekey \
    && git -C /filekey fetch --depth 1 https://github.com/RockwellShah/filekey.git a08cfd75228e6878d62eeaabb11728a9f166017e \
    && git -C /filekey checkout FETCH_HEAD

# Stage 2: Serve static files with Nginx
# nginx:stable-alpine
FROM nginx@sha256:15e96e59aa3b0aada3a121296e3bce117721f42d88f5f64217ef4b18f458c6ab

COPY --from=build /filekey /usr/share/nginx/html

EXPOSE 80

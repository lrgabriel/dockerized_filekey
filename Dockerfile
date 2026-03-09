# Stage 1: Clone the FileKey repository
FROM alpine:3.19 AS build

RUN apk add --no-cache git

RUN git clone --branch main --depth 1 https://github.com/RockwellShah/filekey.git /filekey

# Stage 2: Serve static files with Nginx
FROM nginx:alpine

COPY --from=build /filekey /usr/share/nginx/html

EXPOSE 80

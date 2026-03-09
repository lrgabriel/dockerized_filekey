# Serve FileKey static files with Nginx.
# filekey/ is checked out as a git submodule (see .gitmodules); the exact commit
# being built is pinned by the submodule reference and verified by the workflow.
FROM nginx:stable-alpine@sha256:15e96e59aa3b0aada3a121296e3bce117721f42d88f5f64217ef4b18f458c6ab

COPY filekey /usr/share/nginx/html

EXPOSE 80

# Serve FileKey static files with Nginx.
# filekey/ is checked out as a git submodule (see .gitmodules); the exact commit
# being built is pinned by the submodule reference and verified by the workflow.
FROM nginx:stable-alpine@sha256:87add5f1c1dae6da99a45966b2689b707580bc330065fa03312964b4242d7a99

COPY filekey /usr/share/nginx/html

EXPOSE 80

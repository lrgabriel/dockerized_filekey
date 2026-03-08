# dockerized_filekey

Automated Docker image builds for [RockwellShah/filekey](https://github.com/RockwellShah/filekey), served via Nginx and published to the GitHub Container Registry (GHCR).

## What this repo does

- Clones the upstream FileKey repository at build time
- Packages the static files inside an `nginx:alpine` container
- Publishes multi-arch images (`linux/amd64`, `linux/arm64`) to GHCR

## Triggering a build

Builds are **manual only**. To trigger one:

1. Go to **Actions → Build and Push FileKey Docker Image**
2. Click **Run workflow**
3. Enter the version string (e.g. `0.0.1`)
4. Click **Run workflow**

Three tags are pushed for each build:

| Tag | Example |
|-----|---------|
| `v{version}` | `v0.0.1` |
| `latest` | `latest` |
| `v{version}-{short-sha}` | `v0.0.1-abc1234` |

A GitHub Release named **FileKey v{version}** is also created automatically.

## Pulling an image

```bash
docker pull ghcr.io/lrgabriel/dockerized_filekey:latest
docker run -p 8080:80 ghcr.io/lrgabriel/dockerized_filekey:latest
```

Then open <http://localhost:8080> in your browser.

## Images on GHCR

<https://github.com/lrgabriel/dockerized_filekey/pkgs/container/dockerized_filekey>

## Upstream

<https://github.com/RockwellShah/filekey>

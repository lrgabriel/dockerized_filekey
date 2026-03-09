# Version Pins

All Docker base images and upstream source dependencies are pinned to immutable
digests or commit SHAs to guarantee reproducible, auditable builds.

## Docker Base Images

| Stage   | Image              | Tag           | Digest                                                                   | Pinned On  |
|---------|--------------------|---------------|--------------------------------------------------------------------------|------------|
| Runtime | `nginx`            | `stable-alpine`| `sha256:15e96e59aa3b0aada3a121296e3bce117721f42d88f5f64217ef4b18f458c6ab` | 2026-03-09 |

## Upstream Source

`RockwellShah/filekey` is tracked as a git submodule (see `.gitmodules`). The
submodule reference pins the exact commit SHA being built. Dependabot opens PRs
when new commits appear on the upstream `main` branch.

| Dependency               | Repository                                         | Commit SHA                                 | Commit Date | Pinned On  |
|--------------------------|----------------------------------------------------|--------------------------------------------|-------------|------------|
| RockwellShah/filekey     | https://github.com/RockwellShah/filekey            | `a08cfd75228e6878d62eeaabb11728a9f166017e` | 2025-11-23  | 2026-03-09 |

## How to Update

### Docker base images

1. Find the new image digest from Docker Hub (Tags tab → click tag → copy Digest).
2. Update the relevant `FROM` line in `Dockerfile`.
3. Update the table above with the new digest and today's date.

### RockwellShah/filekey upstream

Dependabot creates a PR automatically when new commits are available. To update
manually:

1. Run `git submodule update --remote filekey` to fetch the latest commit.
2. Run `git add filekey` and commit the result.
3. The workflow will verify the new commit's GPG signature before building.

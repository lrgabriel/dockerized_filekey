# Version Pins

All Docker base images and upstream source dependencies are pinned to immutable
digests or commit SHAs to guarantee reproducible, auditable builds.

## Docker Base Images

| Stage   | Image              | Tag           | Digest                                                                   | Pinned On  |
|---------|--------------------|---------------|--------------------------------------------------------------------------|------------|
| Build   | `alpine`           | `3.23.3`      | `sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659` | 2026-03-09 |
| Runtime | `nginx`            | `stable-alpine`| `sha256:15e96e59aa3b0aada3a121296e3bce117721f42d88f5f64217ef4b18f458c6ab` | 2026-03-09 |

## Upstream Source

| Dependency               | Repository                                         | Commit SHA                                 | Commit Date | Pinned On  |
|--------------------------|----------------------------------------------------|--------------------------------------------|-------------|------------|
| RockwellShah/filekey     | https://github.com/RockwellShah/filekey            | `a08cfd75228e6878d62eeaabb11728a9f166017e` | 2025-11-23  | 2026-03-09 |

## How to Update

When newer versions are available:

1. Find the new image digest from Docker Hub (Tags tab → click tag → copy Digest).
2. Update the relevant `FROM` line in `Dockerfile`.
3. Update the table above with the new digest and today's date.
4. For `RockwellShah/filekey`, find the commit SHA from
   https://github.com/RockwellShah/filekey/commits/main, update the
   `git checkout` line in `Dockerfile`, and update the table above.

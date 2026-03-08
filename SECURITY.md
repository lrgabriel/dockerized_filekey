# Security

This document describes the supply-chain security practices for the
`ghcr.io/lrgabriel/dockerized_filekey` container image.

---

## Table of Contents

1. [Supply-Chain Security Overview](#supply-chain-security-overview)
2. [Build Verification](#build-verification)
3. [Image Signing and Validation (Cosign)](#image-signing-and-validation-cosign)
4. [Recommended Scanning Tools](#recommended-scanning-tools)
5. [Reporting a Vulnerability](#reporting-a-vulnerability)
6. [Incident Response](#incident-response)

---

## Supply-Chain Security Overview

| Control | Implementation |
|---|---|
| Pinned base images | All `FROM` lines use `image:tag@sha256:<digest>` |
| Pinned GitHub Actions | All `uses:` references are pinned by commit SHA |
| Non-root runtime | Container runs as the built-in `nginx` user (uid 101) |
| Minimal attack surface | Final image is `nginx:alpine`; no shell, no package manager |
| Immutable tags | Images are tagged `latest`, `YYYY-MM-DD`, and `YYYY-MM-DD-<sha>` |
| Build provenance | Every build generates a signed SLSA provenance attestation |
| SBOM | Software Bill of Materials (SBOM) attached to every image push |
| Cosign keyless signing | Images are signed using GitHub OIDC (no long-lived keys) |
| Audit log | Build manifests are stored as Actions artifacts for 90 days |

---

## Build Verification

### Verifying the build came from this repository

Every image push generates a signed [SLSA provenance](https://slsa.dev/) attestation.
You can inspect it with the GitHub CLI:

```bash
gh attestation verify \
  oci://ghcr.io/lrgabriel/dockerized_filekey:latest \
  --repo lrgabriel/dockerized_filekey
```

### Verifying the pinned base-image digests

The `Dockerfile` pins each base image by its `sha256` digest. To confirm a
digest matches the published image:

```bash
docker buildx imagetools inspect nginx:1.26.2-alpine
```

Compare the reported digest against the value in `Dockerfile`. If they differ,
the image has changed and the `Dockerfile` should be reviewed before use.

### Reproducible builds

The `FILEKEY_REF` build-arg is pinned to a specific upstream tag or commit SHA.
Passing the same `FILEKEY_REF` to `docker build` will always produce a
bit-for-bit identical layer (modulo timestamps).

```bash
docker build \
  --build-arg FILEKEY_REF=<tag-or-sha> \
  -t dockerized_filekey:local .
```

---

## Image Signing and Validation (Cosign)

Images are signed with [Cosign](https://github.com/sigstore/cosign) using
**keyless signing** via GitHub OIDC. No private key material is stored in this
repository or as a GitHub secret.

### Installing Cosign

```bash
# macOS / Linux (Homebrew)
brew install cosign

# Linux (direct binary)
curl -sSfL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 \
  -o cosign && chmod +x cosign && sudo mv cosign /usr/local/bin/
```

### Verifying an image signature

```bash
COSIGN_EXPERIMENTAL=1 cosign verify \
  --certificate-identity-regexp="https://github.com/lrgabriel/dockerized_filekey/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/lrgabriel/dockerized_filekey:latest
```

A successful verification prints the Fulcio certificate and the Rekor
transparency-log entry. Any failure means the image was **not** signed by this
repository's CI/CD pipeline and should **not** be trusted.

### Verifying the SBOM

```bash
cosign download sbom ghcr.io/lrgabriel/dockerized_filekey:latest
```

---

## Recommended Scanning Tools

Run any of the following against the published image before deploying it:

| Tool | Command |
|---|---|
| [Trivy](https://github.com/aquasecurity/trivy) | `trivy image ghcr.io/lrgabriel/dockerized_filekey:latest` |
| [Grype](https://github.com/anchore/grype) | `grype ghcr.io/lrgabriel/dockerized_filekey:latest` |
| [Docker Scout](https://docs.docker.com/scout/) | `docker scout cves ghcr.io/lrgabriel/dockerized_filekey:latest` |
| [Snyk](https://snyk.io/) | `snyk container test ghcr.io/lrgabriel/dockerized_filekey:latest` |

For automated scanning in your own CI/CD pipeline, we recommend Trivy or
Docker Scout integrated as a pull-request gate.

---

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Report vulnerabilities by emailing the maintainer directly or by using
[GitHub's private vulnerability reporting](https://github.com/lrgabriel/dockerized_filekey/security/advisories/new).

We aim to acknowledge reports within **72 hours** and to release a fix within
**14 days** for critical/high severity issues.

---

## Incident Response

### If a compromised base image is discovered

1. Open a high-priority issue (or use private advisory reporting).
2. Update the `FROM` digest in `Dockerfile` to a known-good image.
3. Trigger a manual workflow dispatch (`workflow_dispatch`) to rebuild and
   republish.
4. Announce the new digest in the GitHub release notes.

### If a signing key or token is compromised

Because this project uses **keyless Cosign signing**, there are no long-lived
keys to rotate. If the CI/CD pipeline itself is compromised:

1. Revoke the GitHub Actions OIDC token (rotate `GITHUB_TOKEN` permissions).
2. Audit the Rekor transparency log for unexpected signatures:
   ```bash
   rekor-cli search --email <github-actions-email>
   ```
3. Republish the image from a clean environment and re-sign it.
4. Notify users to re-verify the image with the new signature.

### If a VirusTotal scan returns a positive result

1. Do **not** deploy or distribute the flagged image.
2. Investigate the upstream `FILEKEY_REF` for tampering.
3. Pin to a previous known-good `FILEKEY_REF` and rebuild.
4. Report the suspicious upstream commit to the upstream maintainer.

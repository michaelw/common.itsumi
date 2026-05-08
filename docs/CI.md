# CI/CD and Publishing

## Automated Workflows

This library chart uses GitHub Actions for validation and release:

- **CI** runs on pull requests and pushes to `main`.
  - `Pre-commit` runs all configured hooks with `pre-commit==4.5.1`.
  - `Helm validation` lints the library chart and renders the fixture application chart in `test/fixtures/common-itsumi-fixture`.
  - `Starter template` generates a chart from `starter-template/` with Copier and verifies that the generated chart can build, lint, and render.

- **Release Please** runs on pushes to `main`.
  - `michaelw-release-bot` creates and updates release PRs.
  - Release tags keep the existing component format, for example `common.itsumi-v0.5.1`.
  - When a release is created, the workflow packages the chart and pushes it to GHCR as an OCI Helm chart.

## Publishing Location

Helm push targets the parent chart namespace:

```bash
helm push dist/common.itsumi-0.5.1.tgz oci://ghcr.io/michaelw/charts
```

Users pull, install, or upgrade the chart with the full chart reference:

```bash
helm pull oci://ghcr.io/michaelw/charts/common.itsumi --version 0.5.1
```

Application charts should use:

```yaml
dependencies:
  - name: common.itsumi
    version: 0.5.x
    repository: oci://ghcr.io/michaelw/charts
```

## Required Repository Settings

- Enable GitHub auto-merge.
- Protect `main`.
- Require pull requests before merging.
- Require branches to be up to date before merging.
- Require status checks:
  - `Pre-commit`
  - `Helm validation`
  - `Starter template`
- Use merge commits for Renovate auto-merge.

## Required Secrets

The Release Please workflow uses a GitHub App token from `michaelw-release-bot`.
Configure these repository secrets:

- `RELEASE_PLEASE_APP_CLIENT_ID`
- `RELEASE_PLEASE_APP_PRIVATE_KEY`

The app installation needs read/write access for contents, issues, and pull requests.

## Manual Published Chart Test

After a release, run **Test Published Chart** manually with the released version,
without a leading `v`. The workflow logs in to GHCR and validates:

```bash
helm pull oci://ghcr.io/michaelw/charts/common.itsumi --version VERSION
helm show chart oci://ghcr.io/michaelw/charts/common.itsumi --version VERSION
helm show values oci://ghcr.io/michaelw/charts/common.itsumi --version VERSION
```

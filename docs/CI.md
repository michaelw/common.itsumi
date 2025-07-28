# CI/CD and Publishing

## Automated Workflows

This library chart uses GitHub Actions for continuous integration and deployment:

- **CI Workflow**: Runs on every pull request and push to main/master

  - Lints and validates the chart
  - Tests template rendering
  - Validates documentation consistency

- **Release Workflow**: Automatically publishes to GHCR on GitHub releases

  - Packages the chart as an OCI artifact
  - Publishes to `ghcr.io/michaelw/common.itsumi`

- **Security & Quality**: Automated security scanning and documentation validation
  - Weekly security scans
  - Documentation consistency checks
  - PR validation with multiple test configurations

## Manual Release Process

1. Update the version in `Chart.yaml`
2. Create a new GitHub release with a tag (e.g., `v0.2.0`)
3. The release workflow will automatically:
   - Package the chart
   - Publish to GHCR
   - Update release notes

## Using Published Charts

```yaml
# Chart.yaml
dependencies:
  - name: common.itsumi
    version: 0.1.0
    repository: oci://ghcr.io/michaelw
```

```bash
# Update dependencies
helm dependency update

# Or pull directly
helm pull oci://ghcr.io/michaelw/common.itsumi --version 0.1.0
```

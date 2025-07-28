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

## Using Published Charts

```yaml
# Chart.yaml
dependencies:
  - name: common.itsumi
    version: 0.2.0
    repository: oci://ghcr.io/michaelw
```

```bash
# Update dependencies
helm dependency update

# Or pull directly
helm pull oci://ghcr.io/michaelw/common.itsumi
```

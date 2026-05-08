# Development

## Local Validation

Run these checks before opening or updating a pull request:

```bash
pre-commit run --all-files
helm dependency build .
helm lint .
helm show chart .
helm show values .
helm dependency build test/fixtures/common-itsumi-fixture
helm template common-itsumi-fixture test/fixtures/common-itsumi-fixture --namespace common-itsumi
```

`common.itsumi` is a Helm library chart, so `helm template common.itsumi .`
is expected to fail with `library charts are not installable`. Use the fixture
application chart to validate rendered resources.

## Starter Template Validation

The starter template is a Copier template. To test it locally against this
checkout:

```bash
tmpdir="$(mktemp -d)"
copier copy --trust --defaults --skip-tasks . "$tmpdir/starter-chart"
STARTER_CHART="$tmpdir/starter-chart" python -c 'from pathlib import Path; import os; p=Path(os.environ["STARTER_CHART"])/"Chart.yaml"; p.write_text(p.read_text().replace("repository: oci://ghcr.io/michaelw/charts", "repository: file://" + os.getcwd()))'
helm dependency build "$tmpdir/starter-chart"
helm lint "$tmpdir/starter-chart"
helm template common-itsumi-starter "$tmpdir/starter-chart" --namespace common-itsumi
```

## Release Flow

Releases are managed by Release Please using the Helm release strategy.
Conventional Commit messages drive version bumps and changelog generation.

Existing release tags use the component-prefixed format, such as
`common.itsumi-v0.5.1`, and new releases should keep that format.

When Release Please creates a release, GitHub Actions:

1. Validates that `Chart.yaml` version matches the Release Please version.
2. Builds chart dependencies.
3. Packages the chart into `dist/common.itsumi-VERSION.tgz`.
4. Pushes the chart to `oci://ghcr.io/michaelw/charts`.
5. Uploads the chart package to the GitHub Release.
6. Pulls and inspects the published chart from GHCR.

## Published Chart References

Use the parent namespace when pushing:

```bash
helm push dist/common.itsumi-VERSION.tgz oci://ghcr.io/michaelw/charts
```

Use the full chart reference when pulling, installing, or upgrading:

```bash
helm pull oci://ghcr.io/michaelw/charts/common.itsumi --version VERSION
helm install my-release oci://ghcr.io/michaelw/charts/common.itsumi --version VERSION
helm upgrade my-release oci://ghcr.io/michaelw/charts/common.itsumi --version VERSION
```

Consumer chart dependencies should use:

```yaml
dependencies:
  - name: common.itsumi
    version: 0.5.x
    repository: oci://ghcr.io/michaelw/charts
```

## Release Bot Configuration

The Release Please workflow uses `michaelw-release-bot` through
`actions/create-github-app-token`. The GitHub App must be installed on this
repository with read/write access for contents, issues, and pull requests.

Required repository secrets:

- `RELEASE_PLEASE_APP_CLIENT_ID`
- `RELEASE_PLEASE_APP_PRIVATE_KEY`

## Manual Published Chart Test

Use the **Test Published Chart** workflow when you want to verify a chart
version that is already published. Pass the version without a leading `v`.

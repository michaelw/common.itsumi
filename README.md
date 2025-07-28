# common.itsumi Library Chart

[![CI](https://github.com/michaelw/common.itsumi/actions/workflows/ci.yml/badge.svg)](https://github.com/michaelw/common.itsumi/actions/workflows/ci.yml)
[![Release](https://github.com/michaelw/common.itsumi/actions/workflows/semantic-release.yml/badge.svg)](https://github.com/michaelw/common.itsumi/actions/workflows/semantic-release.yml)

A [Helm Library Chart](https://helm.sh/docs/topics/library_charts/#helm) for grouping common logic and templates for Kubernetes applications.

## TL;DR

```yaml
dependencies:
  - name: common.itsumi
    version: 0.1.x
    repository: oci://ghcr.io/michaelw
```

```console
helm dependency update
```

```yaml
{{- include "common.itsumi.deployments.tpl" . }}
{{- include "common.itsumi.services.tpl" . }}
{{- include "common.itsumi.configmaps.tpl" . }}
{{- include "common.itsumi.secrets.tpl" . }}
{{- include "common.itsumi.jobs.tpl" . }}
# ...
```

```yaml
# Global configuration for all images
global:
  imageRegistry: "registry.example.com"
```

## Introduction

This chart provides common template helpers and Kubernetes resource templates that can be used to develop new charts using [Helm](https://helm.sh) package manager. It extends the functionality of the Bitnami common library with additional templates specifically designed for modern application deployment patterns.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Features

### Core Resource Templates

- **Deployments**: Comprehensive deployment templates with multi-container support
- **Services**: Service templates with advanced configuration options
- **ConfigMaps**: Configuration management with template rendering
- **Secrets**: Secret management with multiple data formats
- **Jobs**: Job templates for maintenance tasks and migrations
- **HPA**: Horizontal Pod Autoscaler with advanced scaling behaviors

### Advanced Features

- **Argo Rollouts**: Progressive delivery with canary and blue-green deployments
- **Gateway API**: HTTP Routes and gRPC Routes for modern traffic management
- **Ingress**: Traditional Kubernetes Ingress with comprehensive TLS support
- **Multi-Resource Support**: Deploy multiple instances of the same resource type
- **Extra Objects**: Deploy arbitrary Kubernetes resources alongside standard templates

### Template Helpers

All helpers from the [Bitnami common library](https://github.com/bitnami/charts/tree/main/bitnami/common) are available, plus additional functionality specific to this library.

## Global Configuration

### Image Registry Override

The library supports global image registry configuration that allows you to override the registry for all images used across deployments, jobs, init containers, and sidecar containers. This is particularly useful for:

- **Air-gapped environments**: Pull all images from an internal registry
- **Registry migration**: Switch from one registry to another without updating individual image configurations
- **Development environments**: Use a local registry for testing

**Configuration:**

```yaml
global:
  # Global registry prepended to all image names
  imageRegistry: "registry.example.com"
```

**How it works:**

- If an individual image has a `registry` field set, it is prepended to the image repository name
- The `global.imageRegistry` is prepended to all image repository names, it takes precedence over the individual settings
- The global configuration is passed to the Bitnami `common.images.image` helper which handles the registry logic

**Examples:**

- **Use internal registry for all images:**

  ```yaml
  global:
    imageRegistry: "registry.example.com"

  image:
    repository: "myapp/web" # Results in: registry.example.com/myapp/web
    tag: "v1.0.0"

  deployments:
    api:
      image:
        repository: "myapp/api" # Results in: registry.example.com/myapp/api
        tag: "v1.0.0"
    worker:
      image:
        repository: "myapp/worker" # Results in: registry.example.com/myapp/worker
        tag: "v1.0.0"
  ```

- **Override registry for specific images:**

  ```yaml
  global:
    imageRegistry: "internal-registry.com"

  image:
    repository: "myapp/web" # Uses: internal-registry.com/myapp/web
    tag: "v1.0.0"

  deployments:
    api:
      image:
        registry: "external-registry.com" # Override: STILL uses internal-registry.com
        repository: "myapp/api" # Results in: internal-registry.com/myapp/api
        tag: "v1.0.0"
  ```

- **Development environment example:**

  ```yaml
  global:
    imageRegistry: "localhost:5000"
  # All images will use localhost:5000 registry unless overridden
  ```

**Supported Image Locations:**

- Main deployment containers
- Multiple deployment containers
- Init containers
- Sidecar containers
- Job containers
- Job init and sidecar containers

## Usage Examples

### Basic Application Chart

Create a simple chart using the library:

```yaml
# Chart.yaml
apiVersion: v2
name: my-app
description: My application chart
type: application
version: 1.0.0
appVersion: "1.0.0"

dependencies:
  - name: common.itsumi
    version: 0.1.0
    repository: https://github.com/michaelw/common.itsumi
```

```yaml
# values.yaml
global:
  imageRegistry: "registry.example.com" # All images will use this registry

replicaCount: 3
image:
  repository: mycompany/myapp # Results in: registry.example.com/mycompany/myapp
  tag: v1.0.0
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  ports:
    http:
      port: 80
      targetPort: 8080

ingress:
  enabled: true
  ingressClassName: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

```yaml
# templates/deployments.yaml
{{ - include "common.itsumi.deployments.tpl" . }}
```

```yaml
# templates/services.yaml
{{ - include "common.itsumi.services.tpl" . }}
```

```yaml
# templates/ingresses.yaml
{{ - include "common.itsumi.ingresses.tpl" . }}
```

### Microservices Architecture

Deploy multiple components with different configurations:

```yaml
# values.yaml
global:
  imageRegistry: "registry.example.com" # All images use company registry

deployments:
  enabled: true

  web:
    enabled: true
    replicaCount: 3
    image:
      repository: myapp/web # Results in: registry.example.com/myapp/web
      tag: v1.0.0
    ports:
      http:
        containerPort: 3000
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
      targetCPUUtilizationPercentage: 70

  api:
    enabled: true
    replicaCount: 2
    image:
      repository: myapp/api # Results in: registry.example.com/myapp/api
      tag: v1.0.0
    ports:
      http:
        containerPort: 4000

  worker:
    enabled: true
    replicaCount: 5
    image:
      repository: myapp/worker # Results in: registry.example.com/myapp/worker
      tag: v1.0.0
    command:
      - bundle
      - exec
      - sidekiq

services:
  enabled: true
  web:
    type: ClusterIP
    ports:
      http:
        port: 80
        targetPort: 3000
    selector:
      component: web
  api:
    type: ClusterIP
    ports:
      http:
        port: 8080
        targetPort: 4000
    selector:
      component: api

jobs:
  migration:
    enabled: true
    command: ["bundle", "exec", "rails", "db:migrate"]
    restartPolicy: Never
    backoffLimit: 3
```

```yaml
# templates/deployments.yaml
{{ - include "common.itsumi.deployments.tpl" . }}
```

```yaml
# templates/services.yaml
{{ - include "common.itsumi.services.tpl" . }}
```

```yaml
# templates/jobs.yaml
{{ - include "common.itsumi.jobs.tpl" . }}
```

```yaml
# templates/hpas.yaml
{{ - include "common.itsumi.hpas.tpl" . }}
```

## Starter Chart

This library includes a [Copier](https://copier.readthedocs.io/)-based starter chart template that provides a complete foundation for new applications. Use it to quickly bootstrap new chart development, after answering a few questions (with sensible defaults):

```bash
# Copy the starter chart
copier copy --trust https://github.com/michaelw/common.itsumi test-service

# The templates are already configured to use common.itsumi
helm template test-service
```

The starter chart includes templates for:

- Deployments
- Services
- Ingress and HTTPRoutes/GRPCRoutes
- ConfigMaps and Secrets
- Jobs and HPA
- Argo Rollouts
- Extra objects

## Template Reference

The following table lists the template helpers available in this library:

### Deployment Templates

| Template Helper                 | Description          | Usage                                             |
| ------------------------------- | -------------------- | ------------------------------------------------- |
| `common.itsumi.deployments.tpl` | Deployments template | `{{ include "common.itsumi.deployments.tpl" . }}` |

**Expected Input for default deployment:**

```yaml
replicaCount: 3
image:
  repository: myapp
  tag: v1.0.0
  pullPolicy: IfNotPresent
ports:
  http:
    containerPort: 8080
    protocol: TCP
env:
  NODE_ENV: production
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

**Expected Input for multiple deployments:**

```yaml
deployments:
  default:
    enabled: false
  web:
    enabled: true
    replicaCount: 3
    image:
      repository: myapp-web
      tag: v1.0.0
    ports:
      http:
        containerPort: 3000
  api:
    enabled: true
    replicaCount: 2
    image:
      repository: myapp-api
      tag: v1.0.0
    ports:
      http:
        containerPort: 4000
```

### Service Templates

| Template Helper              | Description       | Usage                                          |
| ---------------------------- | ----------------- | ---------------------------------------------- |
| `common.itsumi.services.tpl` | Services template | `{{ include "common.itsumi.services.tpl" . }}` |

**Expected Input for default service:**

```yaml
service:
  type: ClusterIP
  ports:
    http:
      port: 80
      targetPort: 8080
      protocol: TCP
```

**Expected Input for multiple services:**

```yaml
services:
  enabled: true
  default:
    enabled: false
  web:
    type: ClusterIP
    ports:
      http:
        port: 80
        targetPort: 3000
    selector:
      component: web
  api:
    type: ClusterIP
    ports:
      http:
        port: 8080
        targetPort: 4000
    selector:
      component: api
```

### ConfigMap Templates

| Template Helper                | Description         | Usage                                            |
| ------------------------------ | ------------------- | ------------------------------------------------ |
| `common.itsumi.configmaps.tpl` | ConfigMaps template | `{{ include "common.itsumi.configmaps.tpl" . }}` |

**Expected Input:**

```yaml
configMaps:
  app-config:
    enabled: true
    annotations:
      description: "Application configuration"
    labels:
      config.type: "application"
    immutable: false
    data:
      app.properties: |
        key=value
        debug=true
      config.json: |
        {
          "feature_flags": {
            "new_ui": true
          }
        }
    binaryData:
      certificate.crt: LS0tLS1CRUdJTi...
```

### Secret Templates

| Template Helper             | Description      | Usage                                         |
| --------------------------- | ---------------- | --------------------------------------------- |
| `common.itsumi.secrets.tpl` | Secrets template | `{{ include "common.itsumi.secrets.tpl" . }}` |

**Expected Input:**

```yaml
secrets:
  app-secrets:
    enabled: true
    type: Opaque
    annotations:
      description: "Application secrets"
    labels:
      secret.type: "application"
    immutable: false
    stringData:
      database-password: "supersecret"
      api-key: "abc123"
    data:
      certificate.crt: LS0tLS1CRUdJTi...
```

### Job Templates

| Template Helper          | Description   | Usage                                      |
| ------------------------ | ------------- | ------------------------------------------ |
| `common.itsumi.jobs.tpl` | Jobs template | `{{ include "common.itsumi.jobs.tpl" . }}` |

**Expected Input:**

```yaml
jobs:
  migration:
    enabled: true
    labels:
      job.type: "migration"
    annotations:
      description: "Database migration job"
    backoffLimit: 3
    activeDeadlineSeconds: 600
    ttlSecondsAfterFinished: 3600
    restartPolicy: Never
    command:
      - bundle
      - exec
      - rails
      - db:migrate
    env:
      RAILS_ENV: production
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
```

### HPA Templates

| Template Helper          | Description   | Usage                                      |
| ------------------------ | ------------- | ------------------------------------------ |
| `common.itsumi.hpas.tpl` | HPAs template | `{{ include "common.itsumi.hpas.tpl" . }}` |

**Expected Input:**

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      selectPolicy: Min
      policies:
        conservative:
          type: Percent
          value: 10
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      selectPolicy: Max
      policies:
        fast:
          type: Percent
          value: 50
          periodSeconds: 60
```

### Ingress Templates

| Template Helper               | Description        | Usage                                           |
| ----------------------------- | ------------------ | ----------------------------------------------- |
| `common.itsumi.ingresses.tpl` | Ingresses template | `{{ include "common.itsumi.ingresses.tpl" . }}` |

**Expected Input:**

```yaml
ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: myapp-service
              port:
                number: 80
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
```

### Gateway API Templates

| Template Helper                | Description                  | Usage                                            |
| ------------------------------ | ---------------------------- | ------------------------------------------------ |
| `common.itsumi.httproutes.tpl` | Multiple HTTPRoutes template | `{{ include "common.itsumi.httproutes.tpl" . }}` |
| `common.itsumi.grpcroutes.tpl` | Multiple GRPCRoutes template | `{{ include "common.itsumi.grpcroutes.tpl" . }}` |

**Expected Input for HTTPRoute:**

```yaml
httpRoutes:
  api:
    enabled: true
    spec:
      parentRefs:
        gateway:
          name: my-gateway
          namespace: gateway-system
      hostnames:
        - api.example.com
      rules:
        api-v1:
          matches:
            - path:
                type: PathPrefix
                value: /api/v1
          backendRefs:
            - name: api-service
              port: 8080
```

### Argo Rollouts Templates

| Template Helper              | Description                | Usage                                          |
| ---------------------------- | -------------------------- | ---------------------------------------------- |
| `common.itsumi.rollouts.tpl` | Multiple Rollouts template | `{{ include "common.itsumi.rollouts.tpl" . }}` |

**Expected Input:**

```yaml
rollouts:
  web:
    enabled: true
    replicas: 5
    strategy:
      canary:
        maxSurge: "25%"
        maxUnavailable: 1
        steps:
          - setWeight: 20
          - pause: {}
          - setWeight: 50
          - pause:
              duration: 10m
          - setWeight: 80
          - pause:
              duration: 10m
    selector:
      matchLabels:
        app: web
    template:
      metadata:
        labels:
          app: web
      spec:
        containers:
          - name: web
            image: myapp:v2.0.0
```

### Extra Objects Template

| Template Helper              | Description                         | Usage                                          |
| ---------------------------- | ----------------------------------- | ---------------------------------------------- |
| `common.itsumi.extraObjects` | Render arbitrary Kubernetes objects | `{{ include "common.itsumi.extraObjects" . }}` |

**Expected Input:**

```yaml
extraObjects:
  - |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ include "common.names.fullname" . }}-custom
      namespace: {{ .Release.Namespace }}
    data:
      custom.conf: |
        key=value
  - apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: '{{ include "common.names.fullname" . }}-netpol'
    spec:
      podSelector:
        matchLabels:
          app.kubernetes.io/name: '{{ include "common.names.name" . }}'
      policyTypes:
        - Ingress
        - Egress
```

## Best Practices

### Configuration Structure

```yaml
# Single resource pattern
service:
  enabled: true
  type: ClusterIP
  # ... other config

# Multiple resources pattern
services:
  enabled: true
  web:
    enabled: true
    type: ClusterIP
    # ... web service config
  api:
    enabled: true
    type: ClusterIP
    # ... API service config
```

### Resource Naming

- Resources are automatically named using `common.names.fullname`
- For multiple resources, the resource key is appended: `{fullname}-{resourceKey}`
- Use `useFullname: true` in resource config to override this behavior

### Template Inheritance

- Most pod templates support inheritance from deployment configurations
- Use `inheritFrom: <deployment name>` in job configurations to inherit settings
- Override specific values as needed while maintaining consistency

## Advanced Configuration

### Custom Labels and Annotations

All templates support custom labels and annotations:

```yaml
deployment:
  deploymentAnnotations:
    deployment.kubernetes.io/revision: "1"
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
  podLabels:
    version: v1.0.0
    tier: web
```

### Security Contexts

Configure security at pod and container levels:

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```

### Volume Management

Support for various volume types:

```yaml
volumes:
  config:
    configMap:
      name: app-config
  secrets:
    secret:
      secretName: app-secrets
  data:
    persistentVolumeClaim:
      claimName: app-data
  cache:
    emptyDir:
      sizeLimit: 1Gi

volumeMounts:
  config:
    mountPath: /etc/config
    readOnly: true
  secrets:
    mountPath: /etc/secrets
    readOnly: true
  data:
    mountPath: /var/data
  cache:
    mountPath: /tmp/cache
```

## Troubleshooting

### Common Issues

1. **Missing required fields**: Ensure image repository is specified for all containers
2. **Resource conflicts**: Check for duplicate resource names when using multiple resources
3. **Template errors**: Validate YAML structure and template syntax
4. **Dependency issues**: Run `helm dependency update` after modifying Chart.yaml

### Debug Templates

Use Helm's template debugging features:

```bash
# Render templates without installing
helm template my-release ./my-chart

# Debug specific templates
helm template my-release ./my-chart -s templates/deployment.yaml

# Validate generated manifests
helm template my-release ./my-chart | kubectl apply --dry-run=client -f -
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Update documentation
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Acknowledgments

This library extends the excellent [Bitnami Common Library Chart](https://github.com/bitnami/charts/tree/main/bitnami/common) with additional functionality.

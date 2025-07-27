{{/*
Render extra objects from .extraObjects
Usage:
{{ include "common.itsumi.extraObjects" . }}

The .extraObjects should be a list of Kubernetes manifests as strings or structured objects.
Examples:

extraObjects:
  - |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-custom-config
      namespace: {{ .Release.Namespace }}
    data:
      key: value
  - apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: custom-deployment
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: custom-app
      template:
        metadata:
          labels:
            app: custom-app
        spec:
          containers:
          - name: app
            image: nginx
*/}}
{{- define "common.itsumi.extraObjects" -}}
{{- range .Values.extraObjects }}
---
{{- if typeIs "string" . }}
{{- tpl . $ | nindent 0 }}
{{- else }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Render extra objects with template processing
This variant ensures that all objects are processed through the template engine
*/}}
{{- define "common.itsumi.extraObjectsWithTemplate" -}}
{{- range .Values.extraObjects }}
---
{{- if typeIs "string" . }}
{{- tpl . $ | nindent 0 }}
{{- else }}
{{- tpl (toYaml .) $ | nindent 0 }}
{{- end }}
{{- end }}
{{- end }}

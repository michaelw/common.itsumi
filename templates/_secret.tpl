{{/*
common.itsumi.secret.tpl - Single Secret template
Usage:
  For single secret: {{ include "common.itsumi.secret.tpl" . }}
  For specific secret: {{ include "common.itsumi.secret.tpl" (dict "root" . "secretName" "my-secret" "secretConfig" .Values.secrets.mySecret) }}
*/}}
{{- define "common.itsumi.secret.tpl" -}}
{{- $root := .root | default . }}
{{- $secretName := eq "default" .secretName | ternary nil .secretName | default "" }}
{{- $secretConfig := .secretConfig | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $secretName }}
  {{- if not ($secretConfig.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $secretName }}
  {{- end }}
{{- end }}
{{- $labelContext := dict
    "context" $root
    "customLabels" (dict
      "app.kubernetes.io/component" ($secretName | default "default")
    )
}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $fullName }}
  {{- with $secretConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "common.labels.standard" $labelContext | nindent 4 }}
    {{- with $secretConfig.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $secretConfig.namespace }}
  namespace: {{ . }}
  {{- end }}
type: {{ $secretConfig.type | default "Opaque" }}
{{- with $secretConfig.immutable }}
immutable: {{ . }}
{{- end }}
{{- with $secretConfig.data }}
data:
  {{- range $key, $value := . }}
  {{ $key }}: {{ $value }}
  {{- end }}
{{- end }}
{{- with $secretConfig.stringData }}
stringData:
  {{- range $key, $value := . }}
  {{ $key }}: {{ $value }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
common.itsumi.secrets.tpl - Support for multiple secrets in a single chart
Usage: {{ include "common.itsumi.secrets.tpl" . }}
Expects .Values.secrets to be a dictionary of secret configurations
*/}}
{{- define "common.itsumi.secrets.tpl" -}}
{{- $secrets := .Values.secrets | default dict }}
{{- $globalEnabled := or (not (hasKey $secrets "enabled")) $secrets.enabled }}
{{- if $globalEnabled }}
{{- range $secretName, $secretConfig := $secrets }}
{{- if ne $secretName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $secretConfig "enabled" }}
  {{- $isEnabled = $secretConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.secret.tpl" (dict "root" $ "secretName" $secretName "secretConfig" $secretConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

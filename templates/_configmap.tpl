{{/*
common.itsumi.configmap.tpl - Single ConfigMap template
Usage:
  For single configmap: {{ include "common.itsumi.configmap.tpl" . }}
  For specific configmap: {{ include "common.itsumi.configmap.tpl" (dict "root" . "cmName" "my-config" "cmConfig" .Values.configMaps.myConfig) }}
*/}}
{{- define "common.itsumi.configmap.tpl" -}}
{{- $root := .root | default . }}
{{- $cmName := eq "default" .cmName | ternary nil .cmName | default "" }}
{{- $cmConfig := .cmConfig | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $cmName }}
  {{- if not ($cmConfig.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $cmName }}
  {{- end }}
{{- end }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $fullName }}
  {{- with $cmConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $cmConfig.labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $cmConfig.namespace }}
  namespace: {{ . }}
  {{- end }}
{{- with $cmConfig.immutable }}
immutable: {{ . }}
{{- end }}
{{- with $cmConfig.data }}
data:
  {{- range $key, $value := . }}
  {{- if kindIs "string" $value }}
  {{ $key }}: |-
    {{- $value | nindent 4 }}
  {{- else }}
  {{ $key }}:
    {{- toYaml $value | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- with $cmConfig.binaryData }}
binaryData:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
common.itsumi.configmaps.tpl - Support for multiple configMaps in a single chart
Usage: {{ include "common.itsumi.configmaps.tpl" . }}
Expects .Values.configMaps to be a dictionary of configmap configurations
*/}}
{{- define "common.itsumi.configmaps.tpl" -}}
{{- $configMaps := .Values.configMaps | default dict }}
{{- $globalEnabled := or (not (hasKey $configMaps "enabled")) $configMaps.enabled }}
{{- if $globalEnabled }}
{{- range $cmName, $cmConfig := $configMaps }}
{{- if ne $cmName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $cmConfig "enabled" }}
  {{- $isEnabled = $cmConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.configmap.tpl" (dict "root" $ "cmName" $cmName "cmConfig" $cmConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

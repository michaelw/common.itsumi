{{/*
common.itsumi.rollout.tpl - Single Argo Rollout template
Usage:
  For single rollout: {{ include "common.itsumi.rollout.tpl" . }}
  For specific rollout: {{ include "common.itsumi.rollout.tpl" (dict "root" . "rolloutName" "my-rollout" "rolloutConfig" .Values.rollouts.myRollout) }}
*/}}
{{- define "common.itsumi.rollout.tpl" -}}
{{- $root := .root | default . }}
{{- $rolloutName := eq "default" .rolloutName | ternary nil .rolloutName | default "" }}
{{- $rolloutConfig := .rolloutConfig | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $rolloutName }}
  {{- if not ($rolloutConfig.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $rolloutName }}
  {{- end }}
{{- end }}
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: {{ $fullName }}
  {{- with $rolloutConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.namespace }}
  namespace: {{ . }}
  {{- end }}
spec:
  {{- with $rolloutConfig.replicas }}
  replicas: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.analysis }}
  analysis:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.selector }}
  selector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.workloadRef }}
  workloadRef:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.template }}
  template:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.paused }}
  paused: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.progressDeadlineAbort }}
  progressDeadlineAbort: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.restartAt }}
  restartAt: {{ . }}
  {{- end }}
  {{- with $rolloutConfig.rollbackWindow }}
  rollbackWindow:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $rolloutConfig.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
common.itsumi.rollouts.tpl - Support for multiple Argo Rollouts in a single chart
Usage: {{ include "common.itsumi.rollouts.tpl" . }}
Expects .Values.rollouts to be a dictionary of rollout configurations
*/}}
{{- define "common.itsumi.rollouts.tpl" -}}
{{- $rollouts := .Values.rollouts | default dict }}
{{- $globalEnabled := or (not (hasKey $rollouts "enabled")) $rollouts.enabled }}
{{- if $globalEnabled }}
{{- range $rolloutName, $rolloutConfig := $rollouts }}
{{- if ne $rolloutName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $rolloutConfig "enabled" }}
  {{- $isEnabled = $rolloutConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.rollout.tpl" (dict "root" $ "rolloutName" $rolloutName "rolloutConfig" $rolloutConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

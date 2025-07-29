{{/*
common.itsumi.hpa.tpl - Single HorizontalPodAutoscaler template
Usage:
  For single HPA: {{ include "common.itsumi.hpa.tpl" . }}
  For specific HPA: {{ include "common.itsumi.hpa.tpl" (dict "root" . "deploymentName" "my-deployment" "deploymentConfig" .Values.deployments.myDeployment) }}
*/}}
{{- define "common.itsumi.hpa.tpl" -}}
{{- $root := .root | default . }}
{{- $deploymentName := eq "default" .deploymentName | ternary nil .deploymentName | default "" }}
{{- $deploymentConfig := .deploymentConfig | default $root.Values }}
{{- $hpaConfig := $deploymentConfig.autoscaling | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $deploymentName }}
  {{- if not ($deploymentConfig.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $deploymentName }}
  {{- end }}
{{- end }}
{{- $labelContext := dict
    "context" $root
    "customLabels" (dict
      "app.kubernetes.io/component" ($deploymentName | default "default")
    )
}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $fullName }}
  {{- with $hpaConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "common.labels.standard" $labelContext | nindent 4 }}
    {{- with $hpaConfig.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $hpaConfig.namespace }}
  namespace: {{ . }}
  {{- end }}
spec:
  scaleTargetRef:
    apiVersion: {{ ($hpaConfig.scaleTargetRef).apiVersion | default "apps/v1" }}
    kind: {{ ($hpaConfig.scaleTargetRef).kind | default "Deployment" }}
    name: {{ ($hpaConfig.scaleTargetRef).name | default $fullName }}
  minReplicas: {{ $hpaConfig.minReplicas | default 1 }}
  maxReplicas: {{ $hpaConfig.maxReplicas | default 100 }}
  {{- if $hpaConfig.metrics }}
  metrics:
    {{- range $metricName, $metricConfig := $hpaConfig.metrics }}
    - type: {{ $metricConfig.type }}
      {{- if eq $metricConfig.type "Resource" }}
      resource:
        name: {{ ($metricConfig.resource).name }}
        target:
          type: {{ (($metricConfig.resource).target).type | default "Utilization" }}
          {{- if eq (($metricConfig.resource).target).type "Utilization" }}
          averageUtilization: {{ (($metricConfig.resource).target).averageUtilization }}
          {{- else if eq (($metricConfig.resource).target).type "AverageValue" }}
          averageValue: {{ (($metricConfig.resource).target).averageValue }}
          {{- else if eq (($metricConfig.resource).target).type "Value" }}
          value: {{ (($metricConfig.resource).target).value }}
          {{- end }}
      {{- else if eq $metricConfig.type "Pods" }}
      pods:
        metric:
          name: {{ (($metricConfig.pods).metric).name }}
          {{- with (($metricConfig.pods).metric).selector }}
          selector:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        target:
          type: {{ ($metricConfig.pods).target.type | default "AverageValue" }}
          averageValue: {{ ($metricConfig.pods).target.averageValue }}
      {{- else if eq $metricConfig.type "Object" }}
      object:
        metric:
          name: {{ (($metricConfig.object).metric).name }}
          {{- with (($metricConfig.object).metric).selector }}
          selector:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        target:
          type: {{ (($metricConfig.object).target).type | default "Value" }}
          {{- if eq (($metricConfig.object).target).type "Value" }}
          value: {{ (($metricConfig.object).target).value }}
          {{- else if eq (($metricConfig.object).target).type "AverageValue" }}
          averageValue: {{ (($metricConfig.object).target).averageValue }}
          {{- end }}
        describedObject:
          apiVersion: {{ (($metricConfig.object).describedObject).apiVersion }}
          kind: {{ (($metricConfig.object).describedObject).kind }}
          name: {{ (($metricConfig.object).describedObject).name }}
          {{- with (($metricConfig.object).describedObject).namespace }}
          namespace: {{ . }}
          {{- end }}
      {{- else if eq $metricConfig.type "External" }}
      external:
        metric:
          name: {{ (($metricConfig.external).metric).name }}
          {{- with (($metricConfig.external).metric).selector }}
          selector:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        target:
          type: {{ (($metricConfig.external).target).type | default "Value" }}
          {{- if eq (($metricConfig.external).target).type "Value" }}
          value: {{ (($metricConfig.external).target).value }}
          {{- else if eq (($metricConfig.external).target).type "AverageValue" }}
          averageValue: {{ (($metricConfig.external).target).averageValue }}
          {{- end }}
      {{- else if eq $metricConfig.type "ContainerResource" }}
      containerResource:
        name: {{ ($metricConfig.containerResource).name }}
        container: {{ ($metricConfig.containerResource).container }}
        target:
          type: {{ (($metricConfig.containerResource).target).type | default "Utilization" }}
          {{- if eq (($metricConfig.containerResource).target).type "Utilization" }}
          averageUtilization: {{ (($metricConfig.containerResource).target).averageUtilization }}
          {{- else if eq (($metricConfig.containerResource).target).type "AverageValue" }}
          averageValue: {{ (($metricConfig.containerResource).target).averageValue }}
          {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
  {{- /* Default metrics for backward compatibility */}}
  metrics:
    {{- if $hpaConfig.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $hpaConfig.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if $hpaConfig.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ $hpaConfig.targetMemoryUtilizationPercentage }}
    {{- end }}
  {{- end }}
  {{- with $hpaConfig.behavior }}
  behavior:
    {{- if .scaleDown }}
    scaleDown:
      {{- with .scaleDown.stabilizationWindowSeconds }}
      stabilizationWindowSeconds: {{ . }}
      {{- end }}
      {{- with .scaleDown.selectPolicy }}
      selectPolicy: {{ . }}
      {{- end }}
      {{- if .scaleDown.policies }}
      policies:
        {{- range $policyName, $policyConfig := .scaleDown.policies }}
        - type: {{ $policyConfig.type }}
          value: {{ $policyConfig.value }}
          periodSeconds: {{ $policyConfig.periodSeconds }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if .scaleUp }}
    scaleUp:
      {{- with .scaleUp.stabilizationWindowSeconds }}
      stabilizationWindowSeconds: {{ . }}
      {{- end }}
      {{- with .scaleUp.selectPolicy }}
      selectPolicy: {{ . }}
      {{- end }}
      {{- if .scaleUp.policies }}
      policies:
        {{- range $policyName, $policyConfig := .scaleUp.policies }}
        - type: {{ $policyConfig.type }}
          value: {{ $policyConfig.value }}
          periodSeconds: {{ $policyConfig.periodSeconds }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
common.itsumi.hpas.tpl - Support for multiple HPAs based on deployment configurations
Usage: {{ include "common.itsumi.hpas.tpl" . }}
Iterates through .Values.deployments and creates HPAs for those with autoscaling.enabled
*/}}
{{- define "common.itsumi.hpas.tpl" -}}
{{- $deployments := .Values.deployments | default dict }}
{{- $deployments = dict "default" (omit .Values "deployments") | merge $deployments }}
{{- $globalEnabled := or (not (hasKey $deployments "enabled")) $deployments.enabled }}
{{- if $globalEnabled }}
{{- range $deploymentName, $deploymentConfig := $deployments }}
{{- if ne $deploymentName "enabled" }}
{{- $isDeploymentEnabled := true }}
{{- if hasKey $deploymentConfig "enabled" }}
  {{- $isDeploymentEnabled = $deploymentConfig.enabled }}
{{- end }}
{{- $isAutoscalingEnabled := false }}
{{- if $deploymentConfig.autoscaling }}
  {{- $isAutoscalingEnabled = $deploymentConfig.autoscaling.enabled | default false }}
{{- end }}
{{- if and $isDeploymentEnabled $isAutoscalingEnabled }}
---
{{- include "common.itsumi.hpa.tpl" (dict "root" $ "deploymentName" $deploymentName "deploymentConfig" $deploymentConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

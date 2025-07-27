{{/*
common.itsumi.service.tpl
*/}}
{{- define "common.itsumi.service.tpl" -}}
{{- $root := .root | default . }}
{{- $svcName := eq "default" .svcName | ternary nil .svcName | default "" }}
{{- $svcConfig := .svcConfig | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $svcName }}
  {{- if not ($svcConfig.useFullname | default false) }}
  {{- $fullName = printf "%s-%s" $fullName $svcName }}
  {{- end }}
{{- end }}
apiVersion: v1
kind: Service
metadata:
  name: {{ $fullName }}
  {{- with $svcConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "common.labels.standard" $root | nindent 4 }}
    {{- if $svcName }}
    service.name: {{ $svcName }}
    {{- end }}
    {{- with $svcConfig.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  type: {{ $svcConfig.type | default "ClusterIP" }}
  {{- with $svcConfig.clusterIP }}
  clusterIP: {{ . }}
  {{- end }}
  {{- with $svcConfig.clusterIPs }}
  clusterIPs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $svcConfig.externalIPs }}
  externalIPs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $svcConfig.loadBalancerIP }}
  loadBalancerIP: {{ . }}
  {{- end }}
  {{- with $svcConfig.loadBalancerSourceRanges }}
  loadBalancerSourceRanges:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $svcConfig.loadBalancerClass }}
  loadBalancerClass: {{ . }}
  {{- end }}
  {{- with $svcConfig.externalName }}
  externalName: {{ . }}
  {{- end }}
  {{- with $svcConfig.externalTrafficPolicy }}
  externalTrafficPolicy: {{ . }}
  {{- end }}
  {{- with $svcConfig.internalTrafficPolicy }}
  internalTrafficPolicy: {{ . }}
  {{- end }}
  {{- with $svcConfig.healthCheckNodePort }}
  healthCheckNodePort: {{ . }}
  {{- end }}
  {{- with $svcConfig.publishNotReadyAddresses }}
  publishNotReadyAddresses: {{ . }}
  {{- end }}
  {{- with $svcConfig.sessionAffinity }}
  sessionAffinity: {{ . }}
  {{- end }}
  {{- with $svcConfig.sessionAffinityConfig }}
  sessionAffinityConfig:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $svcConfig.ipFamilyPolicy }}
  ipFamilyPolicy: {{ . }}
  {{- end }}
  {{- with $svcConfig.ipFamilies }}
  ipFamilies:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $svcConfig.allocateLoadBalancerNodePorts }}
  allocateLoadBalancerNodePorts: {{ . }}
  {{- end }}
  {{- if $svcConfig.ports }}
  ports:
    {{- range $name, $port := $svcConfig.ports }}
    {{- $isEnabled := true }}
    {{- if hasKey $port "enabled" }}
      {{- $isEnabled = $port.enabled }}
    {{- end }}
    {{- if $isEnabled }}
    - name: {{ $name }}
      port: {{ $port.port }}
      {{- with $port.targetPort }}
      targetPort: {{ . }}
      {{- end }}
      {{- with $port.protocol }}
      protocol: {{ . }}
      {{- end }}
      {{- with $port.appProtocol }}
      appProtocol: {{ . }}
      {{- end }}
      {{- if and (eq $svcConfig.type "NodePort") $port.nodePort }}
      nodePort: {{ $port.nodePort }}
      {{- end }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- if not (eq $svcConfig.type "ExternalName") }}
  selector:
    {{- include "common.labels.matchLabels" $root | nindent 4 }}
    {{- with $svcConfig.selector }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}

{{- end }}


{{/*
common.itsumi.services.tpl - Support for multiple services in a single chart
Usage: {{ include "common.itsumi.services.tpl" . }}
Expects .Values.services to be a dictionary of service configurations
*/}}
{{- define "common.itsumi.services.tpl" -}}
{{- $services := .Values.services | default dict }}
{{- with .Values.service }}
{{- $services = dict "default" . | merge $services }}
{{- end }}
{{- $globalEnabled := or (not (hasKey $services "enabled")) $services.enabled }}
{{- if $globalEnabled }}
{{- range $svcName, $svcConfig := $services }}
{{- if ne $svcName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $svcConfig "enabled" }}
  {{- $isEnabled = $svcConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.service.tpl" (dict "root" $ "svcName" $svcName "svcConfig" $svcConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

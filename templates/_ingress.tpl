{{/*
common.itsumi.ingress.tpl - Single Ingress template
Usage:
  For single Ingress: {{ include "common.itsumi.ingress.tpl" . }}
  For specific Ingress: {{ include "common.itsumi.ingress.tpl" (dict "root" . "ingressName" "my-ingress" "ingressConfig" .Values.ingresses.myIngress) }}
*/}}
{{- define "common.itsumi.ingress.tpl" -}}
{{- $root := .root | default . }}
{{- $ingressName := eq "default" .ingressName | ternary nil .ingressName | default "" }}
{{- $ingressConfig := .ingressConfig | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $ingressName }}
  {{- if not ($ingressConfig.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $ingressName }}
  {{- end }}
{{- end }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  {{- with $ingressConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "common.labels.standard" $root | nindent 4 }}
    {{- with $ingressConfig.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $ingressConfig.namespace }}
  namespace: {{ . }}
  {{- end }}
spec:
  {{- with $ingressConfig.ingressClassName }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- with $ingressConfig.defaultBackend }}
  defaultBackend:
    {{- if .service }}
    service:
      name: {{ .service.name }}
      port:
        {{- if .service.port.number }}
        number: {{ .service.port.number }}
        {{- else if .service.port.name }}
        name: {{ .service.port.name }}
        {{- end }}
    {{- else if .resource }}
    resource:
      apiGroup: {{ .resource.apiGroup }}
      kind: {{ .resource.kind }}
      name: {{ .resource.name }}
    {{- end }}
  {{- end }}
  {{- if $ingressConfig.tls }}
  tls:
    {{- range $tlsName, $tlsConfig := $ingressConfig.tls }}
    - hosts:
        {{- range $tlsConfig.hosts }}
        - {{ . | quote }}
        {{- end }}
      {{- with $tlsConfig.secretName }}
      secretName: {{ . }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if $ingressConfig.rules }}
  rules:
    {{- range $ruleName, $ruleConfig := $ingressConfig.rules }}
    - {{ with $ruleConfig.host -}}
      host: {{ . | quote }}
      {{ end -}}
      http:
        paths:
          {{- range $pathName, $pathConfig := $ruleConfig.http.paths }}
          - path: {{ $pathConfig.path | default "/" }}
            {{- with $pathConfig.pathType }}
            pathType: {{ . }}
            {{- end }}
            backend:
              {{- if $pathConfig.backend.service }}
              service:
                name: {{ $pathConfig.backend.service.name }}
                port:
                  {{- if $pathConfig.backend.service.port.number }}
                  number: {{ $pathConfig.backend.service.port.number }}
                  {{- else if $pathConfig.backend.service.port.name }}
                  name: {{ $pathConfig.backend.service.port.name }}
                  {{- end }}
              {{- else if $pathConfig.backend.resource }}
              resource:
                apiGroup: {{ $pathConfig.backend.resource.apiGroup }}
                kind: {{ $pathConfig.backend.resource.kind }}
                name: {{ $pathConfig.backend.resource.name }}
              {{- end }}
          {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
common.itsumi.ingresses.tpl - Support for multiple Ingresses in a single chart
Usage: {{ include "common.itsumi.ingresses.tpl" . }}
Expects .Values.ingresses to be a dictionary of Ingress configurations
*/}}
{{- define "common.itsumi.ingresses.tpl" -}}
{{- $ingresses := .Values.ingresses | default dict }}
{{- $globalEnabled := or (not (hasKey $ingresses "enabled")) $ingresses.enabled }}
{{- if $globalEnabled }}
{{- range $ingressName, $ingressConfig := $ingresses }}
{{- if ne $ingressName "enabled" }}
{{- $isEnabled := or (not (hasKey $ingressConfig "enabled")) $ingressConfig.enabled }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.ingress.tpl" (dict "root" $ "ingressName" $ingressName "ingressConfig" $ingressConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

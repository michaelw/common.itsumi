{{/*
common.itsumi.grpcroute.tpl - Single GRPCRoute template
Usage:
  For single GRPCRoute: {{ include "common.itsumi.grpcroute.tpl" . }}
  For specific GRPCRoute: {{ include "common.itsumi.grpcroute.tpl" (dict "root" . "routeName" "my-route" "routeConfig" .Values.grpcRoutes.myRoute) }}
*/}}
{{- define "common.itsumi.grpcroute.tpl" -}}
{{- $root := .root | default . }}
{{- $routeName := eq "default" .routeName | ternary nil .routeName | default "" }}
{{- $routeConfig := .routeConfig | default dict }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $routeName }}
  {{- if not ($routeConfig.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $routeName }}
  {{- end }}
{{- end }}
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: {{ $fullName }}
  {{- with $routeConfig.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $routeConfig.labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $routeConfig.namespace }}
  namespace: {{ . }}
  {{- end }}
spec:
  {{- with ($routeConfig.spec).parentRefs }}
  parentRefs:
    {{- range $parentName, $parentConfig := . }}
    - name: {{ $parentConfig.name }}
      {{- with $parentConfig.namespace }}
      namespace: {{ . }}
      {{- end }}
      {{- with $parentConfig.group }}
      group: {{ . }}
      {{- end }}
      {{- with $parentConfig.kind }}
      kind: {{ . }}
      {{- end }}
      {{- with $parentConfig.sectionName }}
      sectionName: {{ . }}
      {{- end }}
      {{- with $parentConfig.port }}
      port: {{ . }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- with ($routeConfig.spec).hostnames }}
  hostnames:
    {{- range . }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- if ($routeConfig.spec).rules }}
  rules:
    {{- range $ruleName, $ruleConfig := ($routeConfig.spec).rules }}
    - {{ with $ruleConfig.matches -}}
      matches:
        {{- range $matchName, $matchConfig := . }}
        - {{ with $matchConfig.method -}}
          method:
            {{- with .type }}
            type: {{ . }}
            {{- end }}
            {{- with .service }}
            service: {{ . }}
            {{- end }}
            {{- with .method }}
            method: {{ . }}
            {{- end }}
          {{ end -}}
          {{ with $matchConfig.headers -}}
          headers:
            {{- range $headerName, $headerConfig := . }}
            - name: {{ $headerConfig.name }}
              type: {{ $headerConfig.type | default "Exact" }}
              value: {{ $headerConfig.value }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{ end -}}
      {{ with $ruleConfig.filters -}}
      filters:
        {{- range $filterName, $filterConfig := . }}
        - type: {{ $filterConfig.type }}
          {{- if eq $filterConfig.type "RequestHeaderModifier" }}
          requestHeaderModifier:
            {{- with ($filterConfig.requestHeaderModifier).set }}
            set:
              {{- range $setName, $setConfig := . }}
              - name: {{ $setConfig.name }}
                value: {{ $setConfig.value }}
              {{- end }}
            {{- end }}
            {{- with ($filterConfig.requestHeaderModifier).add }}
            add:
              {{- range $addName, $addConfig := . }}
              - name: {{ $addConfig.name }}
                value: {{ $addConfig.value }}
              {{- end }}
            {{- end }}
            {{- with ($filterConfig.requestHeaderModifier).remove }}
            remove:
              {{- range . }}
              - {{ . }}
              {{- end }}
            {{- end }}
          {{- else if eq $filterConfig.type "ResponseHeaderModifier" }}
          responseHeaderModifier:
            {{- with ($filterConfig.responseHeaderModifier).set }}
            set:
              {{- range $setName, $setConfig := . }}
              - name: {{ $setConfig.name }}
                value: {{ $setConfig.value }}
              {{- end }}
            {{- end }}
            {{- with ($filterConfig.responseHeaderModifier).add }}
            add:
              {{- range $addName, $addConfig := . }}
              - name: {{ $addConfig.name }}
                value: {{ $addConfig.value }}
              {{- end }}
            {{- end }}
            {{- with ($filterConfig.responseHeaderModifier).remove }}
            remove:
              {{- range . }}
              - {{ . }}
              {{- end }}
            {{- end }}
          {{- else if eq $filterConfig.type "RequestMirror" }}
          requestMirror:
            backendRef:
              name: {{ (($filterConfig.requestMirror).backendRef).name }}
              {{- with (($filterConfig.requestMirror).backendRef).namespace }}
              namespace: {{ . }}
              {{- end }}
              {{- with (($filterConfig.requestMirror).backendRef).group }}
              group: {{ . }}
              {{- end }}
              {{- with (($filterConfig.requestMirror).backendRef).kind }}
              kind: {{ . }}
              {{- end }}
              {{- with (($filterConfig.requestMirror).backendRef).port }}
              port: {{ . }}
              {{- end }}
              {{- with (($filterConfig.requestMirror).backendRef).weight }}
              weight: {{ . }}
              {{- end }}
          {{- else if eq $filterConfig.type "ExtensionRef" }}
          extensionRef:
            group: {{ ($filterConfig.extensionRef).group }}
            kind: {{ ($filterConfig.extensionRef).kind }}
            name: {{ ($filterConfig.extensionRef).name }}
          {{- end }}
        {{- end }}
      {{ end -}}
      {{ if $ruleConfig.backendRefs -}}
      backendRefs:
        {{- range $backendName, $backendConfig := $ruleConfig.backendRefs }}
        {{- $backendFullName := include "common.names.fullname" $root }}
        {{- if ne "default" $backendName }}
          {{- $backendFullName = printf "%s-%s" $backendFullName $backendName }}
        {{- end }}
        - name: {{ $backendConfig.name | default $backendFullName }}
          {{- with $backendConfig.namespace }}
          namespace: {{ . }}
          {{- end }}
          {{- with $backendConfig.group }}
          group: {{ . }}
          {{- end }}
          {{- with $backendConfig.kind }}
          kind: {{ . }}
          {{- end }}
          {{- with $backendConfig.port }}
          port: {{ . }}
          {{- end }}
          {{- with $backendConfig.weight }}
          weight: {{ . }}
          {{- end }}
          {{- with $backendConfig.filters }}
          filters:
            {{- range $filterName, $filterConfig := . }}
            - type: {{ $filterConfig.type }}
              {{- if eq $filterConfig.type "RequestHeaderModifier" }}
              requestHeaderModifier:
                {{- with ($filterConfig.requestHeaderModifier).set }}
                set:
                  {{- range $setName, $setConfig := . }}
                  - name: {{ $setConfig.name }}
                    value: {{ $setConfig.value }}
                  {{- end }}
                {{- end }}
                {{- with ($filterConfig.requestHeaderModifier).add }}
                add:
                  {{- range $addName, $addConfig := . }}
                  - name: {{ $addConfig.name }}
                    value: {{ $addConfig.value }}
                  {{- end }}
                {{- end }}
                {{- with ($filterConfig.requestHeaderModifier).remove }}
                remove:
                  {{- range . }}
                  - {{ . }}
                  {{- end }}
                {{- end }}
              {{- else if eq $filterConfig.type "ResponseHeaderModifier" }}
              responseHeaderModifier:
                {{- with ($filterConfig.responseHeaderModifier).set }}
                set:
                  {{- range $setName, $setConfig := . }}
                  - name: {{ $setConfig.name }}
                    value: {{ $setConfig.value }}
                  {{- end }}
                {{- end }}
                {{- with ($filterConfig.responseHeaderModifier).add }}
                add:
                  {{- range $addName, $addConfig := . }}
                  - name: {{ $addConfig.name }}
                    value: {{ $addConfig.value }}
                  {{- end }}
                {{- end }}
                {{- with ($filterConfig.responseHeaderModifier).remove }}
                remove:
                  {{- range . }}
                  - {{ . }}
                  {{- end }}
                {{- end }}
              {{- else if eq $filterConfig.type "RequestMirror" }}
              requestMirror:
                backendRef:
                  name: {{ (($filterConfig.requestMirror).backendRef).name }}
                  {{- with (($filterConfig.requestMirror).backendRef).namespace }}
                  namespace: {{ . }}
                  {{- end }}
                  {{- with (($filterConfig.requestMirror).backendRef).group }}
                  group: {{ . }}
                  {{- end }}
                  {{- with (($filterConfig.requestMirror).backendRef).kind }}
                  kind: {{ . }}
                  {{- end }}
                  {{- with (($filterConfig.requestMirror).backendRef).port }}
                  port: {{ . }}
                  {{- end }}
                  {{- with (($filterConfig.requestMirror).backendRef).weight }}
                  weight: {{ . }}
                  {{- end }}
              {{- else if eq $filterConfig.type "ExtensionRef" }}
              extensionRef:
                group: {{ ($filterConfig.extensionRef).group }}
                kind: {{ ($filterConfig.extensionRef).kind }}
                name: {{ ($filterConfig.extensionRef).name }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{ end -}}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
common.itsumi.grpcroutes.tpl - Support for multiple GRPCRoutes in a single chart
Usage: {{ include "common.itsumi.grpcroutes.tpl" . }}
Expects .Values.grpcRoutes to be a dictionary of GRPCRoute configurations
*/}}
{{- define "common.itsumi.grpcroutes.tpl" -}}
{{- $grpcRoutes := .Values.grpcRoutes | default dict }}
{{- $globalEnabled := or (not (hasKey $grpcRoutes "enabled")) $grpcRoutes.enabled }}
{{- if $globalEnabled }}
{{- range $routeName, $routeConfig := $grpcRoutes }}
{{- if ne $routeName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $routeConfig "enabled" }}
  {{- $isEnabled = $routeConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.grpcroute.tpl" (dict "root" $ "routeName" $routeName "routeConfig" $routeConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

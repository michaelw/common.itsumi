{{/*
common.itsumi.httproute.tpl - Single HTTPRoute template
Usage:
  For single HTTPRoute: {{ include "common.itsumi.httproute.tpl" . }}
  For specific HTTPRoute: {{ include "common.itsumi.httproute.tpl" (dict "root" . "routeName" "my-route" "routeConfig" .Values.httpRoutes.myRoute) }}
*/}}
{{- define "common.itsumi.httproute.tpl" -}}
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
kind: HTTPRoute
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
        - {{ with $matchConfig.path -}}
          path:
            type: {{ $matchConfig.path.type | default "PathPrefix" }}
            value: {{ $matchConfig.path.value | default "/" }}
          {{- end }}
          {{- with $matchConfig.headers }}
          headers:
            {{- range $headerName, $headerConfig := . }}
            - name: {{ $headerConfig.name }}
              type: {{ $headerConfig.type | default "Exact" }}
              value: {{ $headerConfig.value }}
            {{- end }}
          {{- end }}
          {{- with $matchConfig.queryParams }}
          queryParams:
            {{- range $paramName, $paramConfig := . }}
            - name: {{ $paramConfig.name }}
              type: {{ $paramConfig.type | default "Exact" }}
              value: {{ $paramConfig.value }}
            {{- end }}
          {{- end }}
          {{- with $matchConfig.method }}
          method: {{ . }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- with $ruleConfig.filters }}
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
          {{- else if eq $filterConfig.type "RequestRedirect" }}
          requestRedirect:
            {{- with ($filterConfig.requestRedirect).scheme }}
            scheme: {{ . }}
            {{- end }}
            {{- with ($filterConfig.requestRedirect).hostname }}
            hostname: {{ . }}
            {{- end }}
            {{- with ($filterConfig.requestRedirect).port }}
            port: {{ . }}
            {{- end }}
            {{- with ($filterConfig.requestRedirect).statusCode }}
            statusCode: {{ . }}
            {{- end }}
            {{- with ($filterConfig.requestRedirect).path }}
            path:
              type: {{ ($filterConfig.requestRedirect).path.type }}
              {{- with (($filterConfig.requestRedirect).path).replaceFullPath }}
              replaceFullPath: {{ . }}
              {{- end }}
              {{- with (($filterConfig.requestRedirect).path).replacePrefixMatch }}
              replacePrefixMatch: {{ . }}
              {{- end }}
            {{- end }}
          {{- else if eq $filterConfig.type "URLRewrite" }}
          urlRewrite:
            {{- with ($filterConfig.urlRewrite).hostname }}
            hostname: {{ . }}
            {{- end }}
            {{- with ($filterConfig.urlRewrite).path }}
            path:
              type: {{ ($filterConfig.urlRewrite).path.type }}
              {{- with (($filterConfig.urlRewrite).path).replaceFullPath }}
              replaceFullPath: {{ . }}
              {{- end }}
              {{- with (($filterConfig.urlRewrite).path).replacePrefixMatch }}
              replacePrefixMatch: {{ . }}
              {{- end }}
            {{- end }}
          {{- else if eq $filterConfig.type "ExtensionRef" }}
          extensionRef:
            group: {{ ($filterConfig.extensionRef).group }}
            kind: {{ ($filterConfig.extensionRef).kind }}
            name: {{ ($filterConfig.extensionRef).name }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- if $ruleConfig.backendRefs }}
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
              {{- else if eq $filterConfig.type "RequestRedirect" }}
              requestRedirect:
                {{- with ($filterConfig.requestRedirect).scheme }}
                scheme: {{ . }}
                {{- end }}
                {{- with ($filterConfig.requestRedirect).hostname }}
                hostname: {{ . }}
                {{- end }}
                {{- with ($filterConfig.requestRedirect).port }}
                port: {{ . }}
                {{- end }}
                {{- with ($filterConfig.requestRedirect).statusCode }}
                statusCode: {{ . }}
                {{- end }}
                {{- with ($filterConfig.requestRedirect).path }}
                path:
                  type: {{ ($filterConfig.requestRedirect).path.type }}
                  {{- with (($filterConfig.requestRedirect).path).replaceFullPath }}
                  replaceFullPath: {{ . }}
                  {{- end }}
                  {{- with (($filterConfig.requestRedirect).path).replacePrefixMatch }}
                  replacePrefixMatch: {{ . }}
                  {{- end }}
                {{- end }}
              {{- else if eq $filterConfig.type "URLRewrite" }}
              urlRewrite:
                {{- with ($filterConfig.urlRewrite).hostname }}
                hostname: {{ . }}
                {{- end }}
                {{- with ($filterConfig.urlRewrite).path }}
                path:
                  type: {{ ($filterConfig.urlRewrite).path.type }}
                  {{- with (($filterConfig.urlRewrite).path).replaceFullPath }}
                  replaceFullPath: {{ . }}
                  {{- end }}
                  {{- with (($filterConfig.urlRewrite).path).replacePrefixMatch }}
                  replacePrefixMatch: {{ . }}
                  {{- end }}
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
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
common.itsumi.httproutes.tpl - Support for multiple HTTPRoutes in a single chart
Usage: {{ include "common.itsumi.httproutes.tpl" . }}
Expects .Values.httpRoutes to be a dictionary of HTTPRoute configurations
*/}}
{{- define "common.itsumi.httproutes.tpl" -}}
{{- $httpRoutes := .Values.httpRoutes | default dict }}
{{- $globalEnabled := or (not (hasKey $httpRoutes "enabled")) $httpRoutes.enabled }}
{{- if $globalEnabled }}
{{- range $routeName, $routeConfig := $httpRoutes }}
{{- if ne $routeName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $routeConfig "enabled" }}
  {{- $isEnabled = $routeConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.httproute.tpl" (dict "root" $ "routeName" $routeName "routeConfig" $routeConfig) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

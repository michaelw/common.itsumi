{{/*
common.itsumi.deployment.tpl
Usage: {{ include "common.itsumi.deployments.tpl" (dict "root" $ "name" $name "deployments" (dict $name  ...)) }}
*/}}
{{- define "common.itsumi.deployment.tpl" -}}
{{- $root := .root | default $ }}
{{- $_ := $root.Chart | required "E: .Chart is required" }}
{{- $_ := $root.Release | required "E: .Release is required" }}
{{- $_ := $root.Values | required "E: .Values is required" }}
{{- $allDeployments := .deployments | required "E: .deployments is required" }}
{{- $deploymentName := eq "default" .deploymentName | ternary nil .deploymentName | default "" }}
{{- $deploymentConfig := $allDeployments | dig ($deploymentName | default "default") nil | required (printf "E: deployments.%s does not exist") }}
{{- with $deploymentConfig }}
{{- $fullName := include "common.names.fullname" $root }}
{{- if $deploymentName }}
  {{- if not (.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $deploymentName }}
  {{- end }}
{{- end }}
apiVersion: {{ include "common.capabilities.deployment.apiVersion" $root }}
kind: Deployment
metadata:
  name: {{ $fullName }}
  {{- with .deploymentAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" $root | nindent 4 }}
spec:
  {{- if not (.autoscaling).enabled }}
  replicas: {{ .replicaCount | default 1 }}
  {{- end }}
  {{- with .strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  {{- with .progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  selector:
    matchLabels: {{- include "common.labels.matchLabels" $root | nindent 6 }}
  template:
    metadata:
      {{- with .podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.labels.matchLabels" $root | nindent 8 }}
        {{- with .podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .serviceAccountName }}
      serviceAccountName: {{ . }}
      {{- end }}
      {{- with .podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .hostNetwork }}
      hostNetwork: {{ . }}
      {{- end }}
      {{- with .hostPID }}
      hostPID: {{ . }}
      {{- end }}
      {{- with .dnsPolicy }}
      dnsPolicy: {{ . }}
      {{- end }}
      {{- with .dnsConfig }}
      dnsConfig:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .hostname }}
      hostname: {{ . }}
      {{- end }}
      {{- with .subdomain }}
      subdomain: {{ . }}
      {{- end }}
      {{- with .schedulerName }}
      schedulerName: {{ . }}
      {{- end }}
      {{- with .priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      {{- with .runtimeClassName }}
      runtimeClassName: {{ . }}
      {{- end }}
      {{- with .restartPolicy }}
      restartPolicy: {{ . }}
      {{- end }}
      {{- with .terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ . }}
      {{- end }}
      {{- with .activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ . }}
      {{- end }}
      {{- with .nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if .initContainers }}
      initContainers:
        {{- range $name, $container := .initContainers }}
        {{- $isEnabled := true }}
        {{- if hasKey $container "enabled" }}
          {{- $isEnabled = $container.enabled }}
        {{- end }}
        {{- if $isEnabled }}
          {{- $inherited := dict }}
          {{- with $container.inheritFrom }}
          {{-   $inherited = $allDeployments | dig . nil | required (printf "E: container %s inherits from non-existent deployment '%s'" $name .) }}
          {{- end }}
        - name: {{ $name }}
          {{- $imageRoot := $container.image | default $inherited.image }}
          {{- $_ := $imageRoot.repository | required (printf "E: missing image repository configuration for container '%s'" $name) }}
          image: {{ include "common.images.image"
                      (dict "imageRoot" $imageRoot
                            "global" $root.Values.global
                            "chart" $root.Chart) }}
          {{- with $imageRoot.pullPolicy }}
          imagePullPolicy: {{ . }}
          {{- end }}
          {{- with $container.command | default $inherited.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.args | default $inherited.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.env | default $inherited.env }}
          env:
            {{- range $name, $value := . }}
            {{- $isEnabled := true }}
            {{- if and (kindIs "map" $value) (hasKey $value "enabled") }}
              {{- $isEnabled = $value.enabled }}
            {{- end }}
            {{- if $isEnabled }}
            - name: {{ $name }}
              {{- if kindIs "map" $value }}
              {{- toYaml (omit $value "enabled") | nindent 14 }}
              {{- else }}
              value: {{ $value | quote }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- end }}
          {{- with $container.envFrom | default $inherited.envFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.resources | default $inherited.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.volumeMounts | default $inherited.volumeMounts }}
          volumeMounts:
            {{- range $mountName, $mount := . }}
            - name: {{ $mount.name | default $mountName }}
              mountPath: {{ $mount.mountPath }}
              {{- with $mount.subPath }}
              subPath: {{ . }}
              {{- end }}
              {{- with $mount.subPathExpr }}
              subPathExpr: {{ . }}
              {{- end }}
              {{- with $mount.readOnly }}
              readOnly: {{ . }}
              {{- end }}
              {{- with $mount.mountPropagation }}
              mountPropagation: {{ . }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- with $container.securityContext | default $inherited.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- $name := $deploymentName | default (include "common.names.name" $root) }}
        - name: {{ $name }}
          {{- $imageRoot := .image }}
          {{- $_ := $imageRoot.repository | required (printf "E: missing image repository configuration for container '%s'" $name) }}
          image: {{ include "common.images.image"
                      (dict "imageRoot" $imageRoot
                            "global" $root.Values.global
                            "chart" $root.Chart) }}
          {{- with $imageRoot.pullPolicy }}
          imagePullPolicy: {{ . }}
          {{- end }}
          {{- with .command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .workingDir }}
          workingDir: {{ . }}
          {{- end }}
          {{- if .ports }}
          ports:
            {{- range $name, $port := .ports }}
            {{- $isEnabled := true }}
            {{- if hasKey $port "enabled" }}
              {{- $isEnabled = $port.enabled }}
            {{- end }}
            {{- if $isEnabled }}
            - name: {{ $name }}
              containerPort: {{ $port.containerPort }}
              {{- with $port.protocol }}
              protocol: {{ . }}
              {{- end }}
              {{- with $port.hostPort }}
              hostPort: {{ . }}
              {{- end }}
              {{- with $port.hostIP }}
              hostIP: {{ . }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- end }}
          {{- if or .env .envFrom }}
          {{- with .env }}
          env:
            {{- range $name, $value := . }}
            {{- $isEnabled := true }}
            {{- if and (kindIs "map" $value) (hasKey $value "enabled") }}
              {{- $isEnabled = $value.enabled }}
            {{- end }}
            {{- if $isEnabled }}
            - name: {{ $name }}
              {{- if kindIs "map" $value }}
              {{- toYaml (omit $value "enabled") | nindent 14 }}
              {{- else }}
              value: {{ $value | quote }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- end }}
          {{- with .envFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- with .resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .lifecycle }}
          lifecycle:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if .volumeMounts }}
          volumeMounts:
            {{- range $name, $mount := .volumeMounts }}
            {{- $isEnabled := true }}
            {{- if hasKey $mount "enabled" }}
              {{- $isEnabled = $mount.enabled }}
            {{- end }}
            {{- if $isEnabled }}
            - name: {{ $mount.name | default $name }}
              mountPath: {{ $mount.mountPath }}
              {{- with $mount.subPath }}
              subPath: {{ . }}
              {{- end }}
              {{- with $mount.subPathExpr }}
              subPathExpr: {{ . }}
              {{- end }}
              {{- with $mount.readOnly }}
              readOnly: {{ . }}
              {{- end }}
              {{- with $mount.mountPropagation }}
              mountPropagation: {{ . }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- end }}
        {{- if .sidecarContainers }}
        {{- range $name, $container := .sidecarContainers }}
        - name: {{ $name }}
          {{- $imageRoot := $container.image }}
          {{- $_ := $imageRoot.repository | required (printf "E: missing image repository configuration for container '%s'" $name) }}
          image: {{ include "common.images.image"
                      (dict "imageRoot" $imageRoot
                            "global" $root.Values.global
                            "chart" $root.Chart) }}
          {{- with $imageRoot.pullPolicy }}
          imagePullPolicy: {{ . }}
          {{- end }}
          {{- with $container.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.env }}
          env:
            {{- range $name, $value := . }}
            {{- $isEnabled := true }}
            {{- if and (kindIs "map" $value) (hasKey $value "enabled") }}
              {{- $isEnabled = $value.enabled }}
            {{- end }}
            {{- if $isEnabled }}
            - name: {{ $name }}
              {{- if kindIs "map" $value }}
              {{- toYaml (omit $value "enabled") | nindent 14 }}
              {{- else }}
              value: {{ $value | quote }}
              {{- end }}
            {{- end }}
            {{- end }}
          {{- end }}
          {{- with $container.envFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.ports }}
          ports:
            {{- range $portName, $port := . }}
            - name: {{ $portName }}
              containerPort: {{ $port.containerPort }}
              {{- with $port.protocol }}
              protocol: {{ . }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- with $container.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.volumeMounts }}
          volumeMounts:
            {{- range $mountName, $mount := . }}
            - name: {{ $mount.name | default $mountName }}
              mountPath: {{ $mount.mountPath }}
              {{- with $mount.subPath }}
              subPath: {{ . }}
              {{- end }}
              {{- with $mount.readOnly }}
              readOnly: {{ . }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- with $container.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $container.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- end }}
      {{- if .volumes }}
      volumes:
        {{- range $name, $volume := .volumes }}
        {{- $isEnabled := true }}
        {{- if hasKey $volume "enabled" }}
          {{- $isEnabled = $volume.enabled }}
        {{- end }}
        {{- if $isEnabled }}
        - name: {{ $name }}
          {{- if $volume.configMap }}
          configMap:
            {{- toYaml $volume.configMap | nindent 12 }}
          {{- else if $volume.secret }}
          secret:
            {{- toYaml $volume.secret | nindent 12 }}
          {{- else if $volume.persistentVolumeClaim }}
          persistentVolumeClaim:
            {{- toYaml $volume.persistentVolumeClaim | nindent 12 }}
          {{- else if $volume.emptyDir }}
          emptyDir:
            {{- toYaml $volume.emptyDir | nindent 12 }}
          {{- else if $volume.hostPath }}
          hostPath:
            {{- toYaml $volume.hostPath | nindent 12 }}
          {{- else if $volume.nfs }}
          nfs:
            {{- toYaml $volume.nfs | nindent 12 }}
          {{- else if $volume.csi }}
          csi:
            {{- toYaml $volume.csi | nindent 12 }}
          {{- else if $volume.projected }}
          projected:
            {{- toYaml $volume.projected | nindent 12 }}
          {{- else if $volume.downwardAPI }}
          downwardAPI:
            {{- toYaml $volume.downwardAPI | nindent 12 }}
          {{- else }}
          {{- toYaml (omit $volume "name" "enabled") | nindent 10 }}
          {{- end }}
        {{- end }}
        {{- end }}
      {{- end }}
{{- end }}
{{- end }}

{{/*
common.itsumi.deployments.tpl - Support for multiple deployments in a single chart
Usage: {{ include "common.itsumi.deployments.tpl" . }}
Expects .Values.deployments to be a dictionary of deployment configurations
*/}}
{{- define "common.itsumi.deployments.tpl" -}}
{{- $deployments := .Values.deployments | default dict }}
{{- $deployments = dict "default" (omit .Values "deployments") | merge $deployments }}
{{- $globalEnabled := or (not (hasKey $deployments "enabled")) $deployments.enabled }}
{{- if $globalEnabled }}
{{- range $deploymentName, $deploymentConfig := $deployments }}
{{- if ne $deploymentName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $deploymentConfig "enabled" }}
  {{- $isEnabled = .enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.deployment.tpl" (dict "root" $ ".name" $deploymentName "deployments" $deployments) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

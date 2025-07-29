{{/*
common.itsumi.job.tpl - Single job template
Usage: {{ include "common.itsumi.job.tpl" (dict "root" $ "name" $name "jobConfig" $config "deployments" $deployments) }}
*/}}
{{- define "common.itsumi.job.tpl" -}}
{{- $root := .root | default $ }}
{{- $_ := $root.Chart | required "E: .Chart is required" }}
{{- $_ := $root.Release | required "E: .Release is required" }}
{{- $_ := $root.Values | required "E: .Values is required" }}
{{- $allDeployments := .deployments | required "E: .deployments is required" }}
{{- $jobName := eq "default" .name | ternary nil .name | default "" }}
{{- with .jobConfig }}
{{- $fullName := include "common.names.fullname" $root }}
{{- $inheritedCtx := dict }}
{{- with .inheritFrom }}
{{-   $inheritedCtx = $allDeployments | dig . nil | required (printf "E: job '%s' inherits from non-existent deployment '%s'" $jobName .) }}
{{- end }}
{{- if $jobName }}
  {{- if not (.useFullname | default false) }}
    {{- $fullName = printf "%s-%s" $fullName $jobName }}
  {{- end }}
{{- end }}
{{- $labelContext := dict
    "context" $root
    "customLabels" (dict
      "app.kubernetes.io/component" ($jobName | default "default")
    )
}}
apiVersion: {{ include "common.capabilities.job.apiVersion" $root }}
kind: Job
metadata:
  name: {{ $fullName }}
  {{- $hook := dict
    "helm.sh/hook" "post-install,post-upgrade,post-rollback"
    "helm.sh/hook-delete-policy" "before-hook-creation"
  }}
  {{- with .annotations | default $hook }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "common.labels.standard" $labelContext | nindent 4 }}
    {{- with .labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- with .parallelism }}
  parallelism: {{ . }}
  {{- end }}
  {{- with .completions }}
  completions: {{ . }}
  {{- end }}
  {{- with .completionMode }}
  completionMode: {{ . }}
  {{- end }}
  {{- with .backoffLimit }}
  backoffLimit: {{ . }}
  {{- end }}
  {{- with .activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ . }}
  {{- end }}
  {{- with .suspend }}
  suspend: {{ . }}
  {{- end }}
  {{- with .manualSelector }}
  manualSelector: {{ . }}
  {{- end }}
  {{- with .selector }}
  selector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .podFailurePolicy }}
  podFailurePolicy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    metadata:
      {{- with (.podAnnotations | default $inheritedCtx.podAnnotations) }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.itsumi.labels.matchLabels" $labelContext | nindent 8 }}
        {{- with (.podLabels | default $inheritedCtx.podLabels) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with $root.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.serviceAccountName | default $inheritedCtx.serviceAccountName) }}
      serviceAccountName: {{ . }}
      {{- end }}
      {{- with (.podSecurityContext | default $inheritedCtx.podSecurityContext) }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.hostNetwork | default $inheritedCtx.hostNetwork) }}
      hostNetwork: {{ . }}
      {{- end }}
      {{- with (.hostPID | default $inheritedCtx.hostPID) }}
      hostPID: {{ . }}
      {{- end }}
      {{- with (.dnsPolicy | default $inheritedCtx.dnsPolicy) }}
      dnsPolicy: {{ . }}
      {{- end }}
      {{- with (.dnsConfig | default $inheritedCtx.dnsConfig) }}
      dnsConfig:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.hostname | default $inheritedCtx.hostname) }}
      hostname: {{ . }}
      {{- end }}
      {{- with (.subdomain | default $inheritedCtx.subdomain) }}
      subdomain: {{ . }}
      {{- end }}
      {{- with (.schedulerName | default $inheritedCtx.schedulerName) }}
      schedulerName: {{ . }}
      {{- end }}
      {{- with (.priorityClassName | default $inheritedCtx.priorityClassName) }}
      priorityClassName: {{ . }}
      {{- end }}
      {{- with (.runtimeClassName | default $inheritedCtx.runtimeClassName) }}
      runtimeClassName: {{ . }}
      {{- end }}
      restartPolicy: {{ .restartPolicy | default "Never" }}
      {{- with (.terminationGracePeriodSeconds | default $inheritedCtx.terminationGracePeriodSeconds) }}
      terminationGracePeriodSeconds: {{ . }}
      {{- end }}
      {{- with (.activeDeadlineSeconds | default $inheritedCtx.activeDeadlineSeconds) }}
      activeDeadlineSeconds: {{ . }}
      {{- end }}
      {{- with (.nodeSelector | default $inheritedCtx.nodeSelector) }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.affinity | default $inheritedCtx.affinity) }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.tolerations | default $inheritedCtx.tolerations) }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.topologySpreadConstraints | default $inheritedCtx.topologySpreadConstraints) }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if (.initContainers | default $inheritedCtx.initContainers) }}
      initContainers:
        {{- range $name, $container := (.initContainers | default $inheritedCtx.initContainers) }}
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
          {{- with $container.restartPolicy }}{{/* do not inherit */}}
          restartPolicy: {{ . }}
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
            {{- $isMountEnabled := true }}
            {{- if hasKey $mount "enabled" }}
              {{- $isMountEnabled = $mount.enabled }}
            {{- end }}
            {{- if $isMountEnabled }}
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
          {{- end }}
          {{- with $container.securityContext | default $inherited.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- $name := $jobName | default (include "common.names.name" $root) }}
        - name: {{ $name }}
          {{- $imageRoot := .image | default $inheritedCtx.image }}
          {{- $_ := $imageRoot.repository | required (printf "E: missing image repository configuration for container '%s'" $name) }}
          image: {{ include "common.images.image"
                      (dict "imageRoot" $imageRoot
                            "global" $root.Values.global
                            "chart" $root.Chart) }}
          {{- with $imageRoot.pullPolicy }}
          imagePullPolicy: {{ . }}
          {{- end }}
          {{- with (.command | default $inheritedCtx.command) }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with (.args | default $inheritedCtx.args) }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with (.workingDir | default $inheritedCtx.workingDir) }}
          workingDir: {{ . }}
          {{- end }}
          {{- /* no ports */}}
          {{- if or (.env | default $inheritedCtx.env) (.envFrom | default $inheritedCtx.envFrom) }}
          {{- with (.env | default $inheritedCtx.env) }}
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
          {{- with (.envFrom | default $inheritedCtx.envFrom) }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- with (.resources | default $inheritedCtx.resources) }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with (.securityContext | default $inheritedCtx.securityContext) }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with (.lifecycle | default $inheritedCtx.lifecycle) }}
          lifecycle:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- /* no probes */}}
          {{- if (.volumeMounts | default $inheritedCtx.volumeMounts) }}
          volumeMounts:
            {{- range $name, $mount := (.volumeMounts | default $inheritedCtx.volumeMounts) }}
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
        {{- if .sidecarContainers | default $inheritedCtx.sidecarContainers }}
        {{- range $name, $container := .sidecarContainers | default $inheritedCtx.sidecarContainers }}
        - name: {{ $name }}
          {{- $imageRoot := $container.image }}
          {{- $_ := $imageRoot.repository | required (printf "E: missing image repository configuration for container '%s'" $name) }}
          image: {{ include "common.images.image"
                      (dict "imageRoot" $imageRoot
                            "global" $root.Values.global
                            "chart" $root.Chart) }}
          {{- with $container.imagePullPolicy }}
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
          {{- /* no ports */}}
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
          {{- /* no ports */}}
        {{- end }}
        {{- end }}
      {{- if .volumes | default $inheritedCtx.volumes }}
      volumes:
        {{- range $name, $volume := .volumes | default $inheritedCtx.volumes }}
        {{- $isEnabled := true }}
        {{- if hasKey $volume "enabled" }}
          {{- $isEnabled = $volume.enabled }}
        {{- end }}
        {{- if $isEnabled }}
        - name: {{ $name }}
          {{- if hasKey $volume "configMap" }}
          configMap:
            {{- $configMapName := include "common.names.fullname" $root }}
            {{- if ne "default" $name }}
              {{- $configMapName = printf "%s-%s" $configMapName $name }}
            {{- end }}
            {{- toYaml (merge (dict "name" ($volume.configMap.name | default $configMapName)) $volume.configMap) | nindent 12 }}
          {{- else if hasKey $volume "secret" }}
          secret:
            {{- $secretName := include "common.names.fullname" $root }}
            {{- if ne "default" $name }}
              {{- $secretName = printf "%s-%s" $secretName $name }}
            {{- end }}
            {{- toYaml (merge (dict "secretName" ($volume.secret.secretName | default $secretName)) $volume.secret) | nindent 12 }}
          {{- else if hasKey $volume "persistentVolumeClaim" }}
          persistentVolumeClaim:
            {{- toYaml $volume.persistentVolumeClaim | nindent 12 }}
          {{- else if hasKey $volume "emptyDir" }}
          emptyDir:
            {{- toYaml $volume.emptyDir | nindent 12 }}
          {{- else if hasKey $volume "hostPath" }}
          hostPath:
            {{- toYaml $volume.hostPath | nindent 12 }}
          {{- else if hasKey $volume "nfs" }}
          nfs:
            {{- toYaml $volume.nfs | nindent 12 }}
          {{- else if hasKey $volume "csi" }}
          csi:
            {{- toYaml $volume.csi | nindent 12 }}
          {{- else if hasKey $volume "projected" }}
          projected:
            {{- toYaml $volume.projected | nindent 12 }}
          {{- else if hasKey $volume "downwardAPI" }}
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
common.itsumi.jobs.tpl - Support for multiple jobs in a single chart
Usage: {{ include "common.itsumi.jobs.tpl" . }}
Expects .Values.jobs to be a dictionary of job configurations
*/}}
{{- define "common.itsumi.jobs.tpl" -}}
{{- $jobs := .Values.jobs | default dict }}
{{- $deployments := .Values.deployments | default dict }}
{{- $deployments = dict "default" (omit .Values "deployments") | merge $deployments }}
{{- $deployments = omit $deployments "enabled" }}
{{- $globalEnabled := or (not (hasKey $jobs "enabled")) $jobs.enabled }}
{{- if $globalEnabled }}
{{- range $jobName, $jobConfig := $jobs }}
{{- if ne $jobName "enabled" }}
{{- $isEnabled := true }}
{{- if hasKey $jobConfig "enabled" }}
  {{- $isEnabled = $jobConfig.enabled }}
{{- end }}
{{- if $isEnabled }}
---
{{- include "common.itsumi.job.tpl" (dict "root" $ "name" $jobName "jobConfig" $jobConfig "deployments" $deployments) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

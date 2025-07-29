{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector
{{ include "common.itsumi.labels.matchLabels" (dict "customLabels" .Values.podLabels "context" $) -}}
*/}}
{{- define "common.itsumi.labels.matchLabels" }}
{{- $labels := include "common.labels.matchLabels" . | fromYaml }}
{{- with .customLabels }}
{{- $labels = merge $labels . }}
{{- end }}
{{- toYaml $labels }}
{{- end }}

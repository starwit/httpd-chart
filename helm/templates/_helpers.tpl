{{/* Generate chart full name */}}
{{- define "httpd-git.fullname" -}}
{{- printf "%s-%s" .Release.Name "httpd-git" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "httpd-git.labels" -}}
app.kubernetes.io/name: {{ include "httpd-git.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
{{- end -}}

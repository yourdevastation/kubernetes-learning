{{- define "frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "frontend.fullname" -}}
{{- $name := include "frontend.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63| trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "frontend.image" -}}
{{- $image := .Values.image.repository | default "andreystryukov/k8s_private_registry" -}}
{{- $tag := .Values.image.tag | default "latest" -}}
{{- printf "%s:%s" $image $tag | quote -}}
{{- end -}}

{{- define "frontend.partOf" -}}
{{- default .Release.Name .Values.parentApp | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "frontend.commonLabels" -}}
app.kubernetes.io/name: {{ include "frontend.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version }}
app.kubernetes.io/component: {{ .Values.component | default "frontend" }}
app.kubernetes.io/part-of: {{ include "frontend.partOf" . }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels }}
{{- end }}
{{- end -}} 

{{- define "frontend.commonAnnotations" -}}
{{- if .Values.commonAnnotations }}
{{- toYaml .Values.commonAnnotations }}
{{- end }}
{{- end -}}

{{- define "frontend.env" -}}
{{- if .Values.appEnv }}
{{- range $key, $value := .Values.appEnv }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}
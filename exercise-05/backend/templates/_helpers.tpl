{{- define "backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "backend.fullname" -}}
{{- $name := include "backend.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63| trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "backend.partOf" -}}
{{- default .Release.Name .Values.parentApp | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "backend.image" -}}
{{- $image := .Values.image.repository | default "andreystryukov/k8s_private_registry" -}}
{{- $tag := .Values.image.tag | default "latest" -}}
{{- printf "%s:%s" $image $tag | quote -}}
{{- end -}}

{{- define "backend.commonLabels" -}}
app.kubernetes.io/name: {{ include "backend.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version }}
app.kubernetes.io/component: {{ .Values.component | default "backend" }}
app.kubernetes.io/part-of: {{ include "backend.partOf" . }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels }}
{{- end }}
{{- end -}} 

{{- define "backend.env" -}}
{{- $overrides := .EnvOverrides | default dict }}
{{- range $key, $value := .Values.appEnv }}
- name: {{ $key }}
  value: {{ (get $overrides $key | default $value) | quote }}
{{- end -}}
{{- end -}}

{{- define "backend.initContainers" -}}
- name: wait-for-db
  image: postgres:alpine
  command:
    - /bin/sh
    - -c
    - |
      until pg_isready -h {{ .Release.Name }}-postgresql-0.{{ .Release.Name }}-postgresql-hl -U {{ .Values.appEnv.POSTGRES_USER }}; do
        echo "waiting for db";
        sleep 2;
      done;
{{- end -}}

{{- define "backend.job.initContainers" -}}
- name: wait-for-db
  image: busybox:1.36
  command:
    - sh
    - -c
    - |
      until nc -z {{ .Release.Name }}-postgresql-0.{{ .Release.Name }}-postgresql-hl 5432; do
        echo "waiting for db";
        sleep 2;
      done;
{{- end -}}
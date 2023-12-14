{{- define "formsflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "formsflow.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "formsflow.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "formsflow.labels" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ template "formsflow.name" . }}
helm.sh/chart: {{ template "formsflow.chartref" . }}
{{- if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
Generates pull secrets from either string or map values.
A map value must be indexable by the key 'name'.
*/}}
{{- define "formsflow.imagePullSecrets" -}}
{{- with .Values.global.imagePullSecrets -}}
imagePullSecrets:
{{- range . -}}
{{- if typeIs "string" . }}
  - name: {{ . }}
{{- else if index . "name" }}
  - name: {{ .name }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "formsflow.postgresUrl" -}}
{{- if index .Values "postgresql-ha.enabled" -}}
{{/* Use postgres info provided by subchart deployment */}}
{{- else -}}
{{- with .Values.global.postgresql -}}
{{ printf "postgresql://%s:%s@%s:%s" .username .password .hostname .port }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "formsflow.mongodbUrl" -}}
{{- if .Values.mongodb.enabled -}}
{{/* Use mongodb info provided by subchart deployment */}}
{{- else -}}
{{- with .Values.global.mongodb -}}
{{ printf "mongodb://%s:%s@%s:%s/%s" .username .password .hostname .port .database }}
{{- end -}}
{{- end -}}
{{- end -}}
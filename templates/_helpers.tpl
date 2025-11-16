{{/*
Expand the name of the chart.
*/}}
{{- define "besvc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "besvc.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "besvc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "besvc.labels" -}}
helm.sh/chart: {{ include "besvc.chart" . }}
{{ include "besvc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "besvc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "besvc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "besvc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "besvc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate environment variables from appSettings
*/}}
{{- define "besvc.envFromAppSettings" -}}
{{- $envPrefix := .Values.config.envPrefix | default "APP_" -}}
{{- range $key, $value := .Values.config.appSettings }}
{{- if kindIs "map" $value }}
{{- range $subKey, $subValue := $value }}
- name: {{ $envPrefix }}{{ $key | upper }}_{{ $subKey | upper }}
  value: {{ $subValue | quote }}
{{- end }}
{{- else }}
- name: {{ $envPrefix }}{{ $key | upper }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

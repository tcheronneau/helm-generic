{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "generic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic.fullname" -}}
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
{{- define "generic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic.labels" -}}
helm.sh/chart: {{ include "generic.chart" . }}
{{ include "generic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "generic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "generic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "generic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
{{- define "toYaml" -}}
  {{- range $key, $value := . -}}
    {{- $map := kindIs "map" $value -}}
    {{- if $map }}
{{ $key }}:
  {{- include "toYaml" $value | indent 2 }}
    {{- else }}
{{ $key }}: {{ $value }}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- define "generic.volume" -}}
  {{- range $name, $data := .Values.volumes -}}
    {{- if eq $data.type "emptyDir" }}
- name: {{ $name }}
  emptyDir: {}
    {{- else if eq $data.type "hostPath" }}
- name: {{ $name }}
  hostPath:
    path: {{ $data.path }}
    {{- else if eq $data.type "pvc" }}
- name: {{ $name }}
  persistentVolumeClaim:
    claimName: {{ $name }}
    {{- else if eq $data.type "configMap" }}
- name: {{ $name }}
  configMap:
    name: {{ $name }}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- define "generic.probe" -}}
  {{- range $serviceName, $data := .Values.services -}}
    {{- if eq $serviceName $.Release.Name }}
      {{- if hasKey $data.ports "http" -}}
livenessProbe:
  tcpSocket:
    port: {{ $data.ports.http.target| default $data.ports.http.number }} 
readinessProbe:
  tcpSocket:
    port: {{ $data.ports.http.target| default $data.ports.http.number }} 
    {{- else -}}
livenessProbe:
  tcpSocket:
    port: {{ $data.ports.tcp.target| default $data.ports.tcp.number }} 
readinessProbe:
  tcpSocket:
    port: {{ $data.ports.tcp.target| default $data.ports.tcp.number }} 
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

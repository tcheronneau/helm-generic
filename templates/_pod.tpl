{{- define "generic.pod" -}}
- name: {{ .Release.Name }}
  {{- with .Values.image }}
  image: {{ .repository }}/{{ .name }}:{{ .tag }}
  imagePullPolicy: {{ .pullPolicy |quote }}
  {{- end }}
  {{- if .Values.command }}
  command:
  {{- range .Values.command }}
  - {{ .|quote }}
  {{- end }}
  {{- end }}
  {{- if .Values.args }}
  args:
  {{- range .Values.args }}
  - {{ .|quote }}
  {{- end }}
  {{- end }}
  env:
  {{- range $key, $value :=  .Values.env }}
  - name: {{ $key }}
    value: {{ $value |quote }}
  {{- end }}
  ports:
  {{- range $k, $v := .Values.services }}
  {{- range $portName, $portData := $v.ports }}
    - containerPort: {{ $portData.target | default $portData.number }}
  {{- if $portData.protocol }}
      protocol: {{ $portData.protocol }}
  {{- end }}
  {{- end }}
  {{- end }}
  volumeMounts:
  {{- if .Values.litestream.enabled }}
  - name: litestream-data
    mountPath: {{ .Values.litestream.path }}
  {{- end }}
  {{- range $k, $v := .Values.volumes }}
  - name: {{ $k }}
    mountPath: {{ $v.mountPath }}
  {{- end }}
  {{- if .Values.services }}
  {{- include "generic.probe" . |nindent 2 }}
  {{- end }}
  {{- if .Values.resources }}
  resources:
  {{- with .Values.resources }}
  {{- if .requests }}
    requests:
      {{- if .requests.cpu }}
      cpu: {{ .requests.cpu }}
      {{- end }}
      memory: {{ .requests.memory }}
    {{- end }}
    {{- if .limits }}
    limits:
      memory: {{ .limits.memory }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end }}

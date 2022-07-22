{{- define "generic.litestream" }}
- name: litestream
  image: litestream/litestream:{{ .Values.litestream.version }}
  args: ['replicate']
  volumeMounts:
  - name: litestream-data
    mountPath: {{ .Values.litestream.path }} 
  - name: {{ .Release.Name }}-litestream 
    mountPath: /etc/litestream.yml
    subPath: litestream.yml
{{- end -}}

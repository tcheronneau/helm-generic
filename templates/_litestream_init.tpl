{{- define "generic.init.litestream" -}}
- name: init-litestream
  image: litestream/litestream:{{ .Values.litestream.version }}
  args: ['restore', '-if-db-not-exists', '-if-replica-exists', '-v', '{{ .Values.litestream.path }}/{{ .Values.litestream.db | default .Release.Name }}.db']
  volumeMounts:
  - name: litestream-data
    mountPath: {{ .Values.litestream.path }} 
  - name: {{ .Release.Name }}-litestream 
    mountPath: /etc/litestream.yml
    subPath: litestream.yml
{{- end -}}

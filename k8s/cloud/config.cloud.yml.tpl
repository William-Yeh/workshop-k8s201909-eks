---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config.cloud
data: 
  TODOAPI_HOST: "TODOAPI_IP_ADDR"  # external IP (ephemeral or static) or domain name
  TODOAPI_PORT: "80"
  TODOAPI_PATH: "api/todo"

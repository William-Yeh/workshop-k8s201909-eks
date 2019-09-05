---
apiVersion: v1
kind: Service
metadata:
  name: todoapi
  labels:
    app: todo
    tier: backend
spec:
  type: LoadBalancer
  #loadBalancerIP: 444.333.222.111  # external IP (ephemeral or static)
  ports:
    - name: http
      port: 80
      targetPort: 80
  selector:
    app: todo
    tier: backend

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todoapi
  labels:
    app: todo
    tier: backend

spec:
  replicas: 3
  selector:
    matchLabels:
      app: todo
      tier: backend
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate

  template:   # pod definition
    metadata:
      labels:
        app: todo
        tier: backend
    spec:
      containers:
        - name: todoapi
          image: ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/todoapi
          #image: ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/todoapi:6.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
      #dnsPolicy: ClusterFirst
      #restartPolicy: Always

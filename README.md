# Todo sample for Kubernetes


## Configurable settings

Store config in the environment (aka the [12-factor app](https://12factor.net/) principles).

Public accessible endpoint for todoapi backend, defined in [config.local.yml](k8s/local/config.local.yml):

 - `TODOAPI_HOST` : default = `localhost`
 - `TODOAPI_PORT` : default = `30080`
 - `TODOAPI_PATH` : default = `/api/todo`

A version for deployment on the cloud is also provided in [config.cloud.yml](k8s/cloud/config.cloud.yml.tpl):

 - `TODOAPI_HOST` : external IP (*static*) or domain name allocated by cloud providers.
 - `TODOAPI_PORT` : default = `80`
 - `TODOAPI_PATH` : default = `/api/todo`


## Architecture

A *dockerized* web app with separate frontend and backend services on *Kubernetes* (both locally and on the cloud).

**Image tags**

To simplify dev flows, from Lab 6.0 the image tags will be only `latest`, or anything [assigned automatically by Skaffold](https://skaffold.dev/docs/how-tos/taggers/).  Use the `stable` tag if you want to pin specific versions.

**Frontend**

Static HTML5 files and jQuery scripts.

Local web endpoint:

- host = `localhost`
- port = `30000`

Cloud web endpoint:

- host = external IP (*ephemeral*) or domain name allocated by cloud providers
- port = `80`

**Backend**

Backend program written in ASP.NET Core.

Local API endpoint:

- host = `localhost`
- port = `TODOAPI_PORT` (default = `30080`)
- path = `TODOAPI_PATH` (default = `/api/todo`)

Cloud API endpoint:

- host = `TODOAPI_HOST` (to be revised in [config.cloud.yml](k8s/cloud/config.cloud.yml.tpl)), external IP (*static*) or domain name allocated by cloud providers
- port = `TODOAPI_PORT` (default = `80`)
- path = `TODOAPI_PATH` (default = `/api/todo`)



## Usage: the local case

### Preparation

1. Create a `todo` namespace for this app:

   ```
   % kubectl create ns todo
   ```

2. Load the ConfigMap content:

   ```
   % kubectl apply -f k8s/local/config.local.yml  -n todo
   % kubectl get configmaps  -n todo
   ```


### Build & Run

1. Use [Skaffold](https://skaffold.dev/) to streamline the build-and-run processes continuously:

   ```
   % skaffold dev  -n todo
   ```

2. Use your browser to visit the web app at http://localhost:30000



## Usage: the cloud case

### Preparation

1. If you're using EKS, do the [eks-steps](eks-steps/README.md) first.

2. Define the `ACCOUNT_ID` environment variable for later use:

   ```
   % export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
   ```

3. Fill in correct image names by modifying the `ACCOUNT_ID` symbols in manifest files, by either:

   ```
   % k8s/cloud/fix-name.py  $ACCOUNT_ID
   ```

   or by the following command if there's no Python3 installed in your Windows:

   ``` 
   C:> docker run  -v %cd%:/mnt  python:3-alpine  \
       /mnt/k8s/cloud/fix-name.py  $ACCOUNT_ID
   ```

4. Create repositories in ECR (Elastic Container Registry) to hold our images:

   ```
   %  $(aws ecr get-login --no-include-email --region us-west-2)
   
   % aws ecr create-repository --repository-name todoapi
   % aws ecr create-repository --repository-name todofrontend
   ```

5. Create a `todo` namespace for this app:

   ```
   % kubectl create ns todo
   ```


### Build & Run

1. Use [Skaffold](https://skaffold.dev/) to deploy the `service/todoapi` and save its allocated address into `TODOAPI_IP_ADDR` environment variable for later use:

   ```
   % skaffold run -p cloud --default-repo ${ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com  -n todo

   % kubectl get svc  -n todo

   % export TODOAPI_IP_ADDR=$(kubectl get svc/todoapi -n todo -o=jsonpath='{.status.loadBalancer..hostname}')
   ```

2. Fill in correct image names and allocated addresses by modifying the `ACCOUNT_ID` and `TODOAPI_IP_ADDR` symbols in manifest files, by either:

   ```
   % k8s/cloud/fix-name.py  $ACCOUNT_ID  $TODOAPI_IP_ADDR
   ```

   or by the following command if there's no Python3 installed in your Windows:

   ``` 
   C:> docker run  -v %cd%:/mnt  python:3-alpine  \
       /mnt/k8s/cloud/fix-name.py  $ACCOUNT_ID  $TODOAPI_IP_ADDR
   ```

3. Load the ConfigMap content:

   ```
   % kubectl apply -f k8s/cloud/config.cloud.yml  -n todo
   % kubectl get configmaps  -n todo
   ```

4. Uncomment the following lines in [skaffold.yaml](skaffold.yaml):

   ```
   profiles:
     - name: cloud
       deploy:
         kubectl:
           manifests:
             #####- k8s/cloud/config.cloud.yml
             - k8s/cloud/todoapi-service.yml
             #####- k8s/cloud/todofrontend-service.yml
   ```

5. Use [Skaffold](https://skaffold.dev/) to streamline the build-and-run process continuously:

   ```
   % skaffold dev -p cloud --default-repo ${ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com  -n todo
   ```

   or as a one-shot build-and-run task:

   ```
   % skaffold run -p cloud --default-repo ${ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com  -n todo
   ```


6. Use your browser to visit the web app at http://FRONTEND_EXTERNAL_IP:80


## Kubernetes dashboard

See [here](k8s-dashboard.md) if you'd like to use [Kubernetes dashboard](https://github.com/kubernetes/dashboard) locally.


## About the source code

The sample was extracted from the TodoApi demo in the Microsoft Docs site, retrieved on Feb 14, 2019:

 - Document - [Tutorial: Create a web API with ASP.NET Core MVC](https://docs.microsoft.com/zh-tw/aspnet/core/tutorials/first-web-api)

 - Source code - https://github.com/aspnet/Docs/tree/master/aspnetcore/tutorials/first-web-api/samples/2.2/TodoApi


The original source code to be used in this repo is packed in the `TodoApi-original.zip` file for your reference.


## LICENSE

Apache License 2.0.  See the [LICENSE](LICENSE) file.


## History

**6.0**: Support Kubernetes on the cloud (EKS for example) and use Skaffold to simplify the process.

**5.0**: Support ConfigMap and naming convention.

**4.0**: Support Kubernetes (locally).

**3.0**: Separate frontend and backend into 2 distinct containers.

**2.0**: Dockerize the app with simple `Dockerfile` and `docker-compose.yml`.

**1.0**: Extracted from Microsoft Docs.

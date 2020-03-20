# Overview

NetFoundry Ziti Tunnel is a networking client that provides access to NetFoundry networks. With Ziti Tunnel running,
other workloads in your cluster can securely connect to remote services. You can also provide services to
remote clients while keeping your cluster completely dark.

For more information on Ziti, see the [Ziti overview](https://netfoundry.github.io/ziti-doc/ziti/overview.html).

# Installation

## Prerequisites

You'll need 

You'll need access to a Ziti Controller before deploying the Ziti Tunnel in your cluster. You can
deploy your own Ziti Controller using the Ziti Edge Developer Edition.

1. Complete the [Ziti Edge Developer Editon quickstart](https://netfoundry.github.io/ziti-doc/ziti/quickstarts/networks-overview.html).

2. Create an identity in the Ziti Edge Controller that will represent the ziti-tunnel nodes in your
   Kubernetes cluster. Download the JWT file for this identity, but do not enroll it. The ziti-tunnel
   GKE application will perform the enrollment automatically.

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install ziti-tunnel to a Google Kubernetes
Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/netfoundry/ziti-tunnel).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/netfoundry/ziti-gcp-marketplace&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/ziti-tunnel)

### Prerequisites

#### Set up command line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [docker](https://docs.docker.com/install/)

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that you
want to use, this step is optional.

```shell
export CLUSTER=ziti-enabled-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

#### Configure kubectl to connect to the cluster

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once for each cluster.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

#### Clone this repo

```shell
git clone https://github.com/netfoundry/ziti-gcp-marketplace.git
```

Navigate to the `k8s/ziti-tunnel` directory:

```shell
cd ziti-gcp-marketplace/k8s/ziti-tunnel
```

#### Pull deployer image

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

And pull the image:

```shell script
docker pull gcr.io/netfoundry-marketplace-public/ziti-tunnel:0.9
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. The instance name will typically match the name of the Ziti identity that
was created in the prerequisites.
 
In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=ziti-tunnel-1
export NAMESPACE=default
export ZITI_ENROLLMENT_TOKEN=$(cat ~/Downloads/$APP_INSTANCE_NAME.jwt)
```

#### Create a namespace in your Kubernetes cluster

If you use a different namespace than `default`, run the command below to create
a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Deploy the application

Use the `mpdev` script to run the deployer:

```shell
./scripts/mpdev install --deployer=gcr.io/netfoundry-marketplace-public/ziti-tunnel/deployer:0.9 \
  --parameters='{"APP_INSTANCE_NAME": "'${APP_INSTANCE_NAME}'", "NAMESPACE":"'${NAMESPACE}'","ZITI_ENROLLMENT_TOKEN":"'${ZITI_ENROLLMENT_TOKEN}'"}'
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

You can watch the pods for the application come up with kubectl:

```shell
kubectl get pods -n $NAMESPACE --watch
```

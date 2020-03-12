# Overview

NetFoundry Ziti Tunnel 

1.  Stand up a NetFoundry network
    - [NetFoundry Console](https://netfoundry.io/) OR
    - [Ziti Edge Developer Edition](https://netfoundry.github.io/ziti-doc/ziti/quickstarts/networks-overview.html)

2. Create an identity. Download the enrollment token (jwt). In this example we name
   the identity "ziti-tunnel-1", and download the jwt to ~/Downloads/ziti-tunnel-1.jwt.

3. Enroll the identity.

    $ docker run -it -v "~/Downloads:/host" --entrypoint ziti-enroller netfoundry/ziti-tunnel:0.5.8-2554 -j /host/ziti-tunnel-1.jwt
    generating P-384 key
    enrolled successfully. identity file written to: /host/ziti-tunnel-1.json

   You should now have a file named "ziti-tunnel-1.json" in your ~/Downloads directory.

3. Create a Kubernetes secret that will be used to inject the ziti-tunnel configuration file into containers. 

    $ kubectl -n $NAMESPACE create secret generic $APP_INSTANCE_NAME --from-file=~/Downloads/ziti-tunnel-1.json

4. 

       
For more information on Ziti Tunnel, see the
[Sample Application website](https://example.com/).

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made
available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Sample Application to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/sample-app).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/sample-app)

### Prerequisites

#### Set up command line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [docker](https://docs.docker.com/install/)
-   [openssl](https://www.openssl.org/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that you
want to use, this step is optional.

```shell
export CLUSTER=sample-app-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

#### Configure kubectl to connect to the cluster

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git clone https://github.com/netfoundry/ziti-gcp-marketplace.git
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

Navigate to the `k8s/ziti-tunnel` directory:

```shell
cd ziti-gcp-marketplace/k8s/ziti-tunnel
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=ziti-tunnel-1
export NAMESPACE=default
export ZITI_ENROLLMENT_TOKEN=$(cat ~/Downloads/$APP_INSTANCE_NAME.jwt)
```

Configure the container images:

```shell
TAG=0.5.8-2554
export IMAGE_ZITI_TUNNEL="marketplace.gcr.io/netfoundry-marketplace-dev/ziti-tunnel:${TAG}"
export IMAGE_ZITI_ENROLLER="marketplace.gcr.io/netfoundry/ziti-tunnel/enroller:${TAG}"
export IMAGE_ZITI_TEST_CONTROLLER="marketplace.gcr.io/netfoundry/ziti-tunnel/test-conroller:${TAG}"
```

The image above is referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images until
you are ready to upgrade. To get the digest for the image, use the following
script:

```shell
for i in "IMAGE_ZITI_TUNNEL" "IMAGE_ZITI_ENROLLER"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Create a namespace in your Kubernetes cluster

If you use a different namespace than `default`, run the command below to create
a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Create the Service Accounts

##### Make sure you are a Cluster Admin

Creating custom cluster roles requires being a Cluster Admin. To assign the
Cluster Admin role to your user account, run the following command:

```shell
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
```

##### Create dedicated Service Accounts

Define the environment variables:

```shell
export ZITI_TUNNEL_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-sa"
export ZITI_ENROLLER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-enroller-sa"
```

Expand the manifest to create Service Accounts:

```shell
cat resources/service-accounts.yaml | envsubst \
  > "${APP_INSTANCE_NAME}_sa_manifest.yaml"
```

Create the accounts on the cluster with `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_sa_manifest.yaml" \
  --namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the expanded
manifest file for future updates to the application.

```shell
awk 'FNR==1 {print "---"}{print}' manifest/* | envsubst \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```
https://console.cloud.google.com/kubernetes/application/us-central1-a/ziti-dev/default/ziti-tunnel-1

To view the app, open the URL in your browser.

# Using the app

## How to use Sample Application

How to use Sample App

## Customize the installation

To set Sample App, follow these on-screen steps to customize your installation:

> Add steps to customize the application, if applicable. Delete this note when
you start editing.

# Scaling

# Backup and restore

How to backup and restore Sample Application

## Backing up Sample Application

## Restoring your data

# Updating

# Logging and Monitoring

![CI](https://github.com/turbaszek/snowplow-gcp-wip/workflows/CI/badge.svg?branch=master)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Snowplow on GCP](#snowplow-on-gcp)
  - [Prerequisites](#prerequisites)
  - [Infrastructure setup](#infrastructure-setup)
  - [Collector deployment](#collector-deployment)
  - [Stream enrich deployment](#stream-enrich-deployment)
  - [BigQuery loader deployment](#bigquery-loader-deployment)
- [Contributing](#contributing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Snowplow on GCP

This project aims to provide set of tools that allow you to easily deploy
[Snowplow](https://github.com/snowplow) setup on [Google Cloud Platform](https://cloud.google.com).

After following all those steps you should have:
- GKE cluster running:
    - Snowplow Scala Stream Collector
    - Beam Enrich
    - BigQuery Loader
- Pub/Sub topics for collector and enrich stream
- BigQuery dataset being the final destination of Snowplow events
- Few GCS buckets

## Prerequisites

To manage GCP resources you have to have installed `gcloud` CLI. For installation options
check the [official documentation](https://cloud.google.com/sdk/install).

This project uses [Terraform](https://www.terraform.io/downloads.html) to bootstrap the infrastructure and
and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to manage the Kubernetes cluster.
On MacOS you should easily install them using [Homebrew](https://brew.sh):
```bash
brew install terraform
brew install kubectl
```
For install option on other systems please check documentation of those projects.

## Infrastructure setup

1. Create GCP project

1. Once you have the project ready run the following script:
    ```bash
    export PROJECT_ID=project-name-here
    export SERVICE_ACCOUNT_NAME=snowplow
    bash scripts/setup-iam.sh ${PROJECT_ID} ${SERVICE_ACCOUNT_NAME}
    ```
   This will create service account in `keys` directory. This service account will have `roles/editor` role.

1. To bootstrap infrastructure required to run Snowplow run:
    ```bash
    export LOCATION=europe-west3
    export GCP_KEY=keys/${SERVICE_ACCOUNT_NAME}.json
    export CLIENT=client-name
    terraform apply -var "gcp_project=${PROJECT_ID}" -var "gcp_location=${LOCATION}" -var "gcp_key_admin=${GCP_KEY}" -var "client=${CLIENT}"
    ```
   The `CLIENT` is a string that is added to all resources name. It's recommended to use
   terraform workspaces i.e. `terraform workspace new my_snowplow`.

## Collector deployment
Check [snowplow documentation](
https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-the-snowplow-collector/).


To get access to the newly create kubernetes cluster run
```bash
gcloud container clusters get-credentials "snowplow-gke" --region ${LOCATION}
```

Collector configuration requires user to provide GCP project id. You can do this running the following
substitution:
```bash
sed -i "" "s/googleProjectId =.*/googleProjectId = ${PROJECT_ID}/" k8s/collector/conf.yaml
```

Then deploy the following CRDs:
```bash
kubectl apply -f k8s/collector/conf.yaml
kubectl apply -f k8s/collector/deploy.yaml
kubectl apply -f k8s/collector/service.yaml
```
This will create `snowplow-collector` deployment which uses [official snowplow image](
https://hub.docker.com/r/snowplow/scala-stream-collector-pubsub/tags)

## Stream enrich deployment
Check [snowplow documentation](
https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-validation-and-enrich-beam-enrich/).


## BigQuery loader deployment
Check [snowplow documentation](
https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-bigquery-destination/bigquery-loader-0-5-0/).


# Contributing

We welcome all contributions! Please submit an issue or PR no matter if it's bug or a typo.

This project is using [pre-commits](https://pre-commit.com) to ensure the
quality of the code. To install pre-commits just do:
```bash
pip install pre-commit
# or
brew install pre-commit
```
And then from project directory run `pre-commit install`.

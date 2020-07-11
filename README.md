<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Snowplow on GCP](#snowplow-on-gcp)
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

## Infrastructure setup

1. Create GCP project
2. Once you have the project ready run the following script:
    ```bash
    export PROJECT_ID=project-name-here
    export SERVICE_ACCOUNT_NAME=snowplow
    bash scripts/setup-iam.sh ${PROJECT_ID} ${SERVICE_ACCOUNT_NAME}
    ```
   This will create service account in `kyes` directory. This service account will have `roles/editor` role.
3. To bootstrap infrastructure reguired to run Snowplow run:
    ```bash
    export GCP_KEY=keys/{$SERVICE_ACCOUNT_NAME}.json
    export CLIENT=client-name
    terraform apply -var "gcp_project=${PROJECT_ID}" -var "gcp_key_admin=${GCP_KEY}" -var "client=${CLIENT}"
    ```
   The `CLIENT` is a string that is added to all resources name.

## Collector deployment

https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-the-snowplow-collector/

## Stream enrich deployment

https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-validation-and-enrich-beam-enrich/

## BigQuery loader deployment

https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-bigquery-destination/bigquery-loader-0-5-0/

# Contributing

We welcome all contributions! This project is using [pre-commits](https://pre-commit.com) to ensure the
quality of the code. To install pre-commits just do:
```bash
pip install pre-commit
# or
brew install pre-commit
```
And then from project directory run `pre-commit install`.

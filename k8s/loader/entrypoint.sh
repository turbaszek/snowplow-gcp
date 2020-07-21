#!/bin/bash

CONFIG=$(cat $1 | base64 -w 0)
RESOLVER=$(cat $2 | base64 -w 0)

./bin/snowplow-bigquery-loader \
    --config="${CONFIG}" \
    --resolver="${RESOLVER}" \
    --runner=DataFlowRunner \
    --jobName=snowplow-bq-loader \
    --project=snowplow-4 \
    --region=europe-west2 \
    --gcpTempLocation=gs://temp-sink-test-lrehwygh/data-dump-bq \

exit 0

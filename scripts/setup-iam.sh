#!/usr/bin/env bash

set -eu

# Arguments:
# $1 - project id
# $2 - name used to create service account
PROJECT_ID=$1
SNOWPLOW_ACCOUNT=$2
KEYS_DIR="keys"

if [[ "${PROJECT_ID}" == "" ]]; then
    echo "No project was specified. Please provide project id as first argument"
    exit 1
fi

if [[ "${SNOWPLOW_ACCOUNT}" == "" ]]; then
    echo "No service account name was specified. Please provide it as second argument"
    exit 1
fi

SERVICE_KEY_PATH="${KEYS_DIR}/${SNOWPLOW_ACCOUNT}.json"
SERVICE_MAIL="${SNOWPLOW_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"

set -eu pi

echo
echo "Using project_id: ${PROJECT_ID}"
echo "Service account to create: ${SNOWPLOW_ACCOUNT}"
echo

gcloud auth login
gcloud config set project ${PROJECT_ID}

set +e
mkdir "${KEYS_DIR}"
gcloud iam service-accounts create "${SNOWPLOW_ACCOUNT}" --display-name="${SNOWPLOW_ACCOUNT}"
gcloud iam service-accounts keys create "${SERVICE_KEY_PATH}" --iam-account="${SERVICE_MAIL}"
set -e

echo
echo "Adding IAM roles/editor to ${SERVICE_MAIL} service account"
echo

gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member "serviceAccount:${SERVICE_MAIL}" \
    --role roles/editor

echo
echo "Enabling services for ${PROJECT_ID} project"
echo

set -x
gcloud services enable dataflow.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable container.googleapis.com

variable "gcp_project" {}
variable "gcp_key_admin" {}
variable "client" {}

locals {
  gcp_region = "europe-west3"
  bq-loader  = "bq-loader"
  collector  = "collector"
  enrich     = "enrich"
}

provider "google" {
  credentials = file(var.gcp_key_admin)
  project     = var.gcp_project
  region      = local.gcp_region
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

######## BUCKETS

resource "google_storage_bucket" "config" {
  name     = "config-${var.client}-${random_string.random.result}"
  location = local.gcp_region

  bucket_policy_only = true

  labels = {
    snowplow = "true",
  }
}

######## Pub/Sub
# Topics for the collector and enrich
# https://github.com/snowplow/snowplow/wiki/GCP:-Setting-up-the-Scala-Stream-Collector

resource "google_pubsub_topic" "good" {
  name = "good"

  labels = {
    snowplow  = "true",
    component = local.collector,
  }
}

resource "google_pubsub_topic" "bad" {
  name = "bad"

  labels = {
    snowplow  = "true",
    component = local.collector,
  }
}

######## BigQuery

locals {
  datasetId = "snowplow"
  tableId   = "events"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id    = local.datasetId
  friendly_name = "snowplow"
  description   = "Dataset used by Snowplow BigQuery loader."
  location      = local.gcp_region

  labels = {
    snowplow  = "true",
    component = local.bq-loader
  }
}

######## GKE

resource "google_container_cluster" "gke" {
  name               = "snowplow-gke"
  location           = local.gcp_region
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      snowplow = "true"
    }

    tags = ["snowplow", "test"]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}

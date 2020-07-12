variable "gcp_project" {}
variable "gcp_location" {}
variable "gcp_key_admin" {}
variable "client" {}

locals {
  bq-loader = "bq-loader"
  collector = "collector"
  enrich    = "enrich"
}

provider "google" {
  credentials = file(var.gcp_key_admin)
  project     = var.gcp_project
  region      = var.gcp_location
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

######## BUCKETS

resource "google_storage_bucket" "config" {
  name     = "config-${var.client}-${random_string.random.result}"
  location = var.gcp_location

  bucket_policy_only = true

  labels = {
    snowplow = "true",
  }
}

resource "google_storage_bucket" "sink" {
  name     = "temp-sink-${var.client}-${random_string.random.result}"
  location = var.gcp_location

  bucket_policy_only = true

  labels = {
    snowplow  = "true",
    component = local.enrich,
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

resource "google_pubsub_topic" "enriched-good" {
  name = "enriched-good"

  labels = {
    snowplow  = "true",
    component = local.enrich,
  }
}

resource "google_pubsub_topic" "bad" {
  name = "bad"

  labels = {
    snowplow  = "true",
    component = local.collector,
  }
}

resource "google_pubsub_topic" "enriched-bad" {
  name = "enriched-bad"

  labels = {
    snowplow  = "true",
    component = local.enrich,
  }
}

resource "google_pubsub_subscription" "snowplow-enrich" {
  name  = "raw-good"
  topic = google_pubsub_topic.good.name

  labels = {
    snowplow  = "true",
    component = local.enrich,
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}

# BigQuery loader subscriptions and topics
# For more information check
# https://docs.snowplowanalytics.com/docs/setup-snowplow-on-gcp/setup-bigquery-destination/bigquery-loader-0-5-0/#topics-and-message-formats

resource "google_pubsub_subscription" "enriched-good-sub" {
  name  = "enriched-good-sub"
  topic = google_pubsub_topic.enriched-good.name

  labels = {
    snowplow  = "true",
    component = local.bq-loader,
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}

resource "google_pubsub_topic" "bq-types" {
  name = "bq-types"

  labels = {
    snowplow  = "true",
    component = local.bq-loader,
  }
}

resource "google_pubsub_subscription" "bq-types-sub" {
  name  = "bq-types-sub"
  topic = google_pubsub_topic.bq-types.name

  labels = {
    snowplow  = "true",
    component = local.bq-loader,
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}

resource "google_pubsub_topic" "bq-bad-rows" {
  name = "bq-bad-rows"

  labels = {
    snowplow  = "true",
    component = local.bq-loader,
  }
}

resource "google_pubsub_topic" "bq-bad-inserts" {
  name = "bq-bad-inserts"

  labels = {
    snowplow  = "true",
    component = local.bq-loader,
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
  location      = var.gcp_location

  labels = {
    snowplow  = "true",
    component = local.bq-loader
  }
}

######## GKE

resource "google_container_cluster" "gke" {
  name               = "snowplow-gke"
  location           = var.gcp_location
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
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/cloud-platform",
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

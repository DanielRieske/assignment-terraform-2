terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.40.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-state-assignment-lb-2"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

provider "random" {

}

locals {
  project = "assignment-terraform-2"
  resource_prefix = "${local.project}-${var.environment}"
}
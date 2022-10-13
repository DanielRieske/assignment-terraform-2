terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.40.0"
    }
  }

#   backend "gcs" {
#     bucket = "assignment-terraform-state"
#   }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

locals {
  project = "assignment-terraform"
}
locals {
  instance_image = "debian-cloud/debian-11"
}

resource "random_id" "instance_template_suffix" {
  byte_length = 6
}

resource "google_compute_instance_template" "web_server" {
  name        = "${local.resource_prefix}-web-server-${random_id.instance_template_suffix.hex}"
  description = "This template is used to create a apache2 web server"

  labels = {
    environment = var.environment
  }

  instance_description = "Instance running a apache2 web server"
  machine_type         = var.machine_type

  disk {
    source_image = local.instance_image
  }

  tags = var.instance_tags

  network_interface {
    network = google_compute_network.vpc_network.id
  }

  service_account {
    email  = google_service_account.instance_service_account.email
    scopes = ["compute-ro"]
  }

  metadata_startup_script = <<SCRIPT
    #!/bin/bash
    apt update 
    apt -y install apache2
    echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
    SCRIPT
}

resource "google_service_account" "instance_service_account" {
  project      = var.project_id
  account_id   = "${local.resource_prefix}-mig"
  display_name = "Service Account used for the managed instance groups"
}

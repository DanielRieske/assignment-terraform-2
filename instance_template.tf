locals {
  instance_image = "debian-cloud/debian-11"
}

resource "random_id" "instance_template_suffix" {
  byte_length = 6
}

resource "google_compute_instance_template" "web_server" {
  name        = "${local.resource_prefix}-web-server-${random_id.instance_template_suffix.hex}"
  description = "This template is used to create a nginx web server"

  labels = {
    environment = var.environment
  }

  instance_description = "Instance running a nginx web server"
  machine_type         = var.machine_type

  disk {
    source_image = local.instance_image
  }

  tags = var.instance_tags

  network_interface {
    network = "default"
  }

  service_account {
    email = google_service_account.instance_service_account.email
    scopes = [ "compute-ro" ]
  }

  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account" "instance_service_account" {
  project      = var.project_id
  account_id   = "${local.resource_prefix}-mig"
  display_name = "Service Account used for the managed instance groups"
}

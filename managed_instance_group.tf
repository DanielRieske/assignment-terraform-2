resource "google_compute_health_check" "autohealing" {
  name                = "${local.resource_prefix}-autohealing-health-check"
  description         = "Autohealing http health check for the managed instance group"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_region_instance_group_manager" "web_server_instance_group" {
  for_each    = var.deploy_regions
  description = "Managed instance group in a region distributed over multiple zones"

  name                      = "${local.resource_prefix}-${each.key}-${random_id.instance_template_suffix.hex}"
  region                    = each.key   # Region
  distribution_policy_zones = each.value # List of zones 
  base_instance_name        = "${local.resource_prefix}-nginx"

  version {
    instance_template = google_compute_instance_template.web_server.id
  }

  target_size = var.instance_count

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 30
  }

  depends_on = [
    google_compute_instance_template.web_server,
    google_compute_health_check.autohealing
  ]
}

resource "google_compute_firewall" "allow_health_check" {
  name          = "${local.resource_prefix}-health-check-firewall"
  description   = "Firewall to allow health checks on the MIG instances"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["allow-health-check"]
}
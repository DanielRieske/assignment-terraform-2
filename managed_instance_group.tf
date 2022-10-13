resource "google_compute_health_check" "autohealing" {
  name                = "${local.resource_prefix}-autohealing-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 3

  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_region_instance_group_manager" "web_server_instance_group" {
  for_each = var.deploy_regions

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
    port = 8080
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
  provider      = google-beta
  direction     = "INGRESS"
  network       = "default"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}
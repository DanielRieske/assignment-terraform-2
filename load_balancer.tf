resource "google_compute_global_address" "global-address" {
  name        = "${local.resource_prefix}-global-address"
  description = "Public IP address of the load balancer"
}

resource "google_compute_global_forwarding_rule" "forwarding-rule" {
  name        = "${local.resource_prefix}-forwarding-rule-port-8080"
  description = "Global external load balancer"
  ip_address  = google_compute_global_address.global-address.id
  port_range  = "80"
  target      = google_compute_target_http_proxy.webserver_proxy.self_link
}

resource "google_compute_target_http_proxy" "webserver_proxy" {
  name        = "${local.resource_prefix}-webserver-proxy"
  description = "Proxy mapping for the Load balancer"
  url_map     = google_compute_url_map.url_map.self_link
}

resource "google_compute_url_map" "url_map" {
  name            = "${local.resource_prefix}-url-map"
  description     = "Url mapping to the backend services"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_backend_service" "backend_service" {
  name        = "${local.resource_prefix}-backend-service"
  description = "Backend service contianing the Managed Instance Group"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10

  dynamic "backend" {
    for_each = google_compute_region_instance_group_manager.web_server_instance_group
    content {
      group = backend.value.instance_group
    }
  }

  health_checks = [google_compute_health_check.autohealing.id]
}
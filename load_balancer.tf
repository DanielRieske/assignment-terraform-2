resource "google_compute_global_address" "global-address" {
  name = "${local.resource_prefix}-global-address"
}

resource "google_compute_global forwarding_rule" "forwarding-rule" {
  name       = "${local.resource_prefix}-forwarding-rule-port-8080"
  ip_address = google_compute_global_address.global-address
  port_range = "8080"
  target     = google_compute_target_http_proxy.webserver_proxy.self_link
}

resource "google_compute_target_http_proxy" "webserver_proxy" {
  name    = "${local.resource_prefix}-webserver-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_url_map" "url_map" {
  name            = "${local.resource_prefix}-url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_backend_service" "backend_service" {
  name        = "${local.resource_prefix}-backend-service"
  protocol    = "HTTP"
  port_name   = "Webserver traffic"
  timeout_sec = 10

  backend {
    for_each = length(google_compute_region_instance_group_manager.web_server_instance_group)
    group    = each.key
  }

  health_checks = google_compute_health_check.autohealing
}
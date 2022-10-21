resource "google_compute_global_address" "global-address" {
  name = "${local.resource_prefix}-global-address"
  description = "Public IP address of the load balancer"
}


resource "google_compute_managed_ssl_certificate" "ssl-certificate" {
  name = "${local.resource_prefix}-ssl-cert"

  managed {
    domains = ["${var.domain}"]
  }
}

resource "google_compute_region_network_endpoint_group" "cloud_run_endpoint_group" {
  for_each = var.deploy_regions
  name = "${local.resource_prefix}-${each.key}-endpoint-group"
  network_endpoint_type = "SERVERLESS"
  region = each.key

  cloud_run {
    service = google_cloud_run_service.cloud_run[each.key].name
  }
}

resource "google_compute_backend_service" "backend_service" {
  name = "${local.resource_prefix}-backend-service"
  description = "Backend service containing the Cloud Run Endpoint Group"
  protocol = "HTTP"
  port_name = "http"

  enable_cdn = true

  dynamic "backend" {
    for_each = google_compute_region_network_endpoint_group.cloud_run_endpoint_group
    content {
      group = backend.value.id
    }
  }
}

resource "google_compute_global_forwarding_rule" "forwarding-rule" {
  name = "${local.resource_prefix}-forwarding-rule-port-443"
  description = "Global external load balancer"
  ip_address = google_compute_global_address.global-address.id
  port_range = "443"
  target = google_compute_target_https_proxy.webserver_proxy.self_link
}

resource "google_compute_target_https_proxy" "webserver_proxy" {
  name = "${local.resource_prefix}-https-proxy"
  description = "Proxy mapping for the Load balancer"
  url_map = google_compute_url_map.url_map.self_link

  ssl_certificates = [ 
    google_compute_managed_ssl_certificate.ssl-certificate.id
  ]
}

resource "google_compute_url_map" "url_map" {
  name            = "${local.resource_prefix}-url-map"
  description     = "Url mapping to the backend services"
  default_service = google_compute_backend_service.backend_service.self_link
}


resource "google_compute_url_map" "http-redirect" {
  name = "http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"  // 301 redirect
    strip_query            = false
    https_redirect         = true
  }
}

resource "google_compute_target_http_proxy" "http-redirect" {
  name    = "http-redirect"
  url_map = google_compute_url_map.http-redirect.self_link
}

resource "google_compute_global_forwarding_rule" "http-redirect" {
  name       = "http-redirect"
  target     = google_compute_target_http_proxy.http-redirect.self_link
  ip_address = google_compute_global_address.global-address.id
  port_range = "80"
}

resource "google_dns_managed_zone" "dns_zone" {
  name     = "${local.resource_prefix}-dns-zone"
  dns_name = "${var.domain}."
}

resource "google_dns_record_set" "record_main" {
  managed_zone = google_dns_managed_zone.dns_zone.name

  name    = "${google_dns_managed_zone.dns_zone.dns_name}"
  type    = "A"
  rrdatas = [google_compute_global_address.global-address.address]
  ttl     = 300
}
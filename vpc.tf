resource "google_compute_network" "vpc_network" {
  name = "${local.resource_prefix}-vpc"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  for_each = { for subnet in var.subnet_configurations : subnet.region => subnet}

  name    = "${local.resource_prefix}-subnet-${each.key}"
  region  = each.key
  network = google_compute_network.vpc_network.id

  ip_cidr_range = each.value.ip_cidr_range
}

resource "google_compute_router" "router" {
  for_each = { for subnet in var.subnet_configurations : subnet.region => subnet}

  name    = "${local.resource_prefix}-router"
  region  = google_compute_subnetwork.vpc_subnet[each.key].region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  for_each = { for subnet in var.subnet_configurations : subnet.region => subnet}

  name                               = "${local.resource_prefix}-nat"
  router                             = google_compute_router.router[each.key].name
  region                             = google_compute_router.router[each.key].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
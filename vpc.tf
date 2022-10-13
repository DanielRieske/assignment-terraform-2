resource "google_compute_network" "vpc_network" {
  name = "${local.resource_prefix}-vpc"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  for_each = var.subnet_configurations

  name    = "${local.resource_prefix}-subnet-${each.key}"
  region  = each.key
  network = google_compute_network.vpc_network.id

  ip_cidr_range = each.value
}

resource "google_compute_network" "vpc_network" {
  name        = "${local.resource_prefix}-vpc"
  description = "Virtual private network for the application"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  for_each    = { for subnet in var.subnet_configurations : subnet.region => subnet }
  description = "Subent for each region in the VPC"
  name        = "${local.resource_prefix}-subnet-${each.key}"
  region      = each.key
  network     = google_compute_network.vpc_network.id

  ip_cidr_range = each.value.ip_cidr_range
}
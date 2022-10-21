output "load_balancer_ip_adress" {
  value = "${google_compute_global_address.global-address}"
  description = "The IP adress of the Load Balancer"

  depends_on = [
    google_compute_global_address.global-address
  ]
}
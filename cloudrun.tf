resource "google_cloud_run_service" "cloud_run" {
    for_each = var.deploy_regions
    name = "${local.resource_prefix}-cloud-run"
    location = each.key

    template {
        spec {
            containers {
              image = "gcr.io/cloudrun/hello"
            }
        }
    }
}

resource "google_cloud_run_service_iam_member" "google_cloud_run_member" {
    for_each = google_cloud_run_service.cloud_run
    service = each.value.name
    role = "roles/run.invoker"
    member = "allUsers"
}
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
    count = length(google_cloud_run_service.cloud_run)
    service = google_cloud_run_service.cloud_run[count.index].name
    role = "roles/run.invoker"
    member = "allUsers"
}
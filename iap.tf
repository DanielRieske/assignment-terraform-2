resource "google_iap_brand" "project_brand" {
  support_email     = "terraform@${var.ADMIN_PROJ_ID}.iam.gserviceaccount.com"
  application_title = "${local.res_prefix}-${local.module_name}"
  project           = google_project_service.project_service["iap.googleapis.com"].project
}
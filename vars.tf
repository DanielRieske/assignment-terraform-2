variable "project_id" {
  type = string
  description = "The project id of the GCP cloud"
}

variable "environment" {
  type = string
  description = "The environment where we deploy the application to"
}

variable "deploy_regions" {
  type = set(map(string, list))
}
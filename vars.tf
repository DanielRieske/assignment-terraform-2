variable "project_id" {
  type        = string
  description = "The project id of the GCP cloud"
}

variable "environment" {
  type        = string
  description = "The environment where we deploy the application to"
}

variable "domain" {
  type        = string
  description = "The domain to deploy the application on"
}

variable "deploy_regions" {
  type        = map(any)
  description = "A set of regions mapped to multiple zones"
}

variable "subnet_configurations" {
  type = set(object({
    region : string
    ip_cidr_range : string
  }))
  description = "Configuration of subnets per region"
}
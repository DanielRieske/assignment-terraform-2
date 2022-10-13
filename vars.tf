variable "project_id" {
  type        = string
  description = "The project id of the GCP cloud"
}

variable "environment" {
  type        = string
  description = "The environment where we deploy the application to"
}

variable "deploy_regions" {
  type        = map(any)
  description = "A set of regions mapped to multiple zones"
}

variable "instance_tags" {
  type        = list(string)
  description = "Tags to set on the compute instances"
}

variable "machine_type" {
  type        = string
  description = "VM machine type"
}

variable "instance_count" {
  type        = number
  description = "Amount of instances in a single managed instance group"
}

variable "subnet_configurations" {
  type = set(object({
    region : string
    ip_cidr_range : string
  }))
  description = "Configuration of subnets per region"
}
environment = "dev"
project_id = "playground-daan"
deploy_regions = {
    europe-west4 = ["europe-west4-a", "europe-west4-b", "europe-west4-c"],
    us-central1  = ["us-central1-a", "us-central1-b", "us-central1-c"] 
}
instance_tags = ["allow-health-check"]
machine_type  = "e2-standard-2"
instance_count = 3
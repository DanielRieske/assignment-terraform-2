environment = "dev"
domain = "dev.playground-daniel.com"
project_id = "playground-daniel-fd08"

deploy_regions = {
    europe-west4 = ["europe-west4-a", "europe-west4-b", "europe-west4-c"],
    us-central1  = ["us-central1-a", "us-central1-b", "us-central1-c"] 
}

subnet_configurations = [
    { 
        region = "europe-west4"
        ip_cidr_range = "172.16.0.0/24" 
    },
    { 
        region = "us-central1"
        ip_cidr_range = "172.16.1.0/24" 
    } 
]
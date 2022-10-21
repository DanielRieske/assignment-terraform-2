environment = "test"
domain = "test.playground-daniel.com"

project_id = "playground-daniel-fd08"
peer_project_id = "playground-justin-4ad1"

deploy_regions = {
    europe-west4 = ["europe-west4-a", "europe-west4-b", "europe-west4-c"],
    europe-west1  = ["europe-west1-a", "europe-west1-b", "europe-west1-c"] 
}

subnet_configurations = [
    { 
        region = "europe-west4" 
        ip_cidr_range = "172.16.20.0/24" 
    },
    { 
        region =  "us-central1"
        ip_cidr_range = "172.16.21.0/24"
    } 
]
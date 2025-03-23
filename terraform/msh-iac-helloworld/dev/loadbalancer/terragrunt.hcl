terraform {
  source = "../../../modules/loadbalancer"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
    name = "dev-msh-cloudfunction-lb"
    project = "robust-root-454606-a7"
    cloud_armor_policy_name = "msh-cloud-armor-policy"
    cloud_armor_policy_ip_ranges = ["45.132.115.0/24"]
    services = [
        {
            service = "simple-hello-world",
            type = "cloud_function",
            path = "/app/*",
            security_policy = "msh-cloud-armor-policy"
        }
    ]
    region = "us-central1"
    https_redirect = false
    ssl = false
    protocol = "HTTP"
}

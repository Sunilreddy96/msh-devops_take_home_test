# GCP Cloud Function with HTTP Load Balancer (dev only)

This repo sets up a Gen2 Python Cloud Function in GCP and exposes it through a global HTTP Load Balancer. The infrastructure is defined using Terraform + Terragrunt, and a helper script is included to simplify deployment.

---

## Prerequisites

Make sure you have the following installed and configured:

- gcloud CLI (https://cloud.google.com/sdk/docs/install)
- Terraform (https://developer.hashicorp.com/terraform/downloads)
- Terragrunt (tested with v0.63.6) (https://terragrunt.gruntwork.io/docs/getting-started/install/)
- A GCP project with billing enabled
- Place your public IP in location terraform/msh-iac-helloworld/dev/loadbalancer/terragrunt.hcl file under cloud_armor_policy_ip_ranges variable and update the project_id accordingly

---

## Execution
- Clone the repo
- Go to scripts path by changing your current dirctory and execute setup.sh script to provison all the required resources and make sure to follow on-screen prompts
- Validate the code by obtaining the IP from load balancer frontend and use curl -v http://<IP>/app/ to confirm the code works . You will be seeing the JSON response "{"message": "Hello, world! Thanks for visiting this page", "status": "success"}". This means that code is working and only works for your IP and rest of the IPs are blocked using cloud aromor policy. If you don't see this response, make sure to double check your system IP and whether you added the same within the terragrunt file or not. For the exact IP use <IP>/32 and for IP range use <IP>/24. 
- Once validated, use the script destroy.sh under scripts folder to destroy all the provisioned resources so that your GCP project is clean. 

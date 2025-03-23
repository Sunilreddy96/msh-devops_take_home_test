# This is global config for all the envs

remote_state {
    backend ="gcs"
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite"
    }
    config = {
        bucket = "msh-terraform-state"
        prefix = "msh/${path_relative_to_include()}/"
        project = "robust-root-454606-a7"
        location = "us"
    }
}
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "google" {
  project = "robust-root-454606-a7"
  region  = "us-central1"
}
EOF
}
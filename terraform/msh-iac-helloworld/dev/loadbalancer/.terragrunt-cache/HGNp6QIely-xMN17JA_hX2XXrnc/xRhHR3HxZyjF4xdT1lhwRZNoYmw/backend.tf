# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "gcs" {
    bucket = "msh-terraform-state"
    prefix = "msh/dev/loadbalancer/"
  }
}

#!/bin/bash
set -e

#Configs
PROJECT_ID="robust-root-454606-a7"
REGION="us-central1"
FUNCTION="simple-hello-world"
BUCKET_NAME="msh-terraform-state"

#Execute Terraform Destroy
echo "Executing terraform destroy to delete resources"
cd ../terraform/msh-iac-helloworld/dev
terragrunt run-all destroy --terragrunt-non-interactive -auto-approve --target=google_compute_backend_service.default
terragrunt run-all destroy --terragrunt-non-interactive -auto-approve

# Delete Cloud Function
echo "Deleting Cloud Function"
gcloud functions delete "$FUNCTION" --region="$REGION" --quiet


# Delete GCS Bucket
echo "Deleting bucket gs://$BUCKET_NAME"
gsutil -m rm -r "gs://$BUCKET_NAME"

# Disable APIs
echo "Disabling necessary APIs"
gcloud services disable compute.googleapis.com cloudfunctions.googleapis.com \
  run.googleapis.com networkservices.googleapis.com iam.googleapis.com \
  monitoring.googleapis.com logging.googleapis.com cloudbuild.googleapis.com \
  artifactregistry.googleapis.com --force

# Revoke ADC
gcloud auth application-default revoke --quiet

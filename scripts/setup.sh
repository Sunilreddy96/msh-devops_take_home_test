#!/bin/bash
set -e

#Configs
PROJECT_ID="robust-root-454606-a7"
REGION="us-central1"
FUNCTION="simple-hello-world"
SOURCE="../cloudFunction"
ENTRY="simple_hello_world"
RUNTIME="python310"
MEMORY="256MB"
BUCKET_NAME="msh-terraform-state"

#Authenticate
echo "Logging in to gcloud"
gcloud auth application-default login

echo "Setting project: $PROJECT_ID"
gcloud config unset project
gcloud config set project "$PROJECT_ID"

#Enable Required APIs
echo "Enabling necessary APIs"
gcloud services enable compute.googleapis.com cloudfunctions.googleapis.com \
  run.googleapis.com networkservices.googleapis.com iam.googleapis.com \
  monitoring.googleapis.com logging.googleapis.com cloudbuild.googleapis.com \
  artifactregistry.googleapis.com


#Deploy Cloud Function
echo "Deploying Cloud Function"
gcloud functions deploy "$FUNCTION" --gen2 --runtime="$RUNTIME" --memory="$MEMORY" --trigger-http \
  --entry-point="$ENTRY" --region="$REGION" \
  --source="$SOURCE" --allow-unauthenticated --quiet

# Create GCP bucket for storing terraform state files
if gsutil ls -b "gs://$BUCKET_NAME" >/dev/null 2>&1; then
  echo "Bucket gs://$BUCKET_NAME already exists."
else
  echo "Creating GCS bucket $BUCKET_NAME"
  gcloud storage buckets create "gs://$BUCKET_NAME" --project="$PROJECT_ID" --location="$REGION" \
    --uniform-bucket-level-access --default-storage-class="STANDARD" --quiet
fi

#Execute Terraform
echo "Executing terraform to provision required resources"
cd ../terraform/msh-iac-helloworld/dev
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply --terragrunt-non-interactive -auto-approve
#!/bin/sh

echo "${CI_GOOGLE_CREDENTIALS}" > gcp-credentials.json
cd gitlab-ci/terraform
terraform init
terraform apply -var project=${GCP_PROJECT} -auto-approve || terraform import -var project=${GCP_PROJECT} module.storage-bucket.google_storage_bucket.default docker-tf-state-stage
cd stage
mv terraform.tfvars.example terraform.tfvars
terraform init
terraform workspace select $CI_COMMIT_REF_SLUG || terraform workspace new $CI_COMMIT_REF_SLUG
terraform destroy -var project=${GCP_PROJECT} -auto-approve
terraform workspace select default
terraform workspace delete $CI_COMMIT_REF_SLUG
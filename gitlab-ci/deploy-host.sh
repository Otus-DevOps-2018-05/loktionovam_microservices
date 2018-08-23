#!/bin/sh
ENVIRONMENT=$1

if [ -z "${ENVIRONMENT}" ]; then
    echo "You must specify environment: depoy-host.sh stage|prod"
    exit 1
fi
# Credentials used by terraform
echo "${CI_GOOGLE_CREDENTIALS}" > gcp-credentials.json
# Credentials used by ansible
echo "${GCE_SERVICE_ACCOUNT}" > "infra/ansible/environments/${ENVIRONMENT}/gce-service-account.json"
cd gitlab-ci/terraform
terraform init
terraform apply -var project=${GCP_PROJECT} -auto-approve || terraform import -var project=${GCP_PROJECT} module.storage-bucket.google_storage_bucket.default docker-tf-state-"${ENVIRONMENT}"
cd "${ENVIRONMENT}"
mv terraform.tfvars.example terraform.tfvars
terraform init
terraform workspace select $CI_COMMIT_REF_SLUG || terraform workspace new $CI_COMMIT_REF_SLUG
terraform taint -module=docker_host null_resource.app || true
terraform apply -var project=${GCP_PROJECT} -auto-approve

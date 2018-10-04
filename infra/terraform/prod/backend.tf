terraform {
  backend "gcs" {
    bucket = "docker-tf-state-prod-20181004001"
    prefix = "terraform/state"
  }
}

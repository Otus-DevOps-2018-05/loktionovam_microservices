terraform {
  backend "gcs" {
    bucket = "docker-tf-state-prod"
    prefix = "terraform/state"
  }
}

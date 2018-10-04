terraform {
  backend "gcs" {
    bucket = "docker-tf-state-stage-20181004001"
    prefix = "terraform/state"
  }
}

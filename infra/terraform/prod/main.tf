provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

data "terraform_remote_state" "state" {
  backend = "gcs"

  config {
    bucket = "docker-tf-state-prod"
  }
}

module "docker_host" {
  source                 = "../modules/docker_host"
  project                = "${var.project}"
  public_key_path        = "${var.public_key_path}"
  private_key_path       = "${var.private_key_path}"
  zone                   = "${var.zone}"
  docker_host_disk_image = "${var.docker_host_disk_image}"
  count                  = "${var.count}"
  size                   = "${var.size}"
  app_provision_enabled  = "${var.app_provision_enabled}"
  environment            = "${var.environment}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = "${var.source_ranges}"
}

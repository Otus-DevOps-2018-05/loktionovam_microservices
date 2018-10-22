provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

data "terraform_remote_state" "state" {
  backend = "gcs"

  config {
    bucket = "kubernetes-tf-state-bucket-20181022001"
  }
}

module "gke" {
  source = "../modules/gke"
  project = "${var.project}"
  region = "${var.region}"
  zone = "${var.zone}"
  cluster_name = "${var.cluster_name}"
  machine_type = "${var.machine_type}"
  size = "${var.size}"
  nodes_count = "${var.nodes_count}"
  min_master_version = "${var.min_master_version}"
}

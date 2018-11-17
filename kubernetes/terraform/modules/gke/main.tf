provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_container_cluster" "kubernetes" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.nodes_count}"
  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false
  node_config {
    disk_size_gb = "${var.size}"
    machine_type = "${var.machine_type}"
  }

  addons_config {
    kubernetes_dashboard = {
      disabled = true
    }
  }
}

resource "google_compute_firewall" "firewall_kubernetes" {
  name    = "allow-kubernetes"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}

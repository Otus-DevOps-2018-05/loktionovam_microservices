provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "docker_host" {
  name         = "${format("docker-host-%03d", count.index + 1)}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  tags  = ["docker-host"]
  count = "${var.count}"

  metadata {
    ssh-keys = "docker-user:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "${var.docker_host_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  connection {
    type        = "ssh"
    user        = "docker-user"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-host"]
}

resource "google_compute_firewall" "firewall_web" {
  name    = "allow-http-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-host"]
}

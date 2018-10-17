provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "mgmt_host" {
  name         = "${format("mgmt-host-${terraform.workspace}-%03d", count.index + 1)}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  tags  = ["mgmt-host", "mgmt-host-${terraform.workspace}"]
  count = "${var.count}"

  metadata {
    ssh-keys = "mgmt-user:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "${var.mgmt_host_disk_image}"
      size  = "${var.size}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      // Ephemeral IP
    }
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/lib/dpkg/lock ; do echo 'dpkg locked, waiting...'; sleep 3;done",
    ]
  }

  provisioner "local-exec" {
    command     = "ansible-playbook playbooks/gce_dynamic_inventory_setup.yml --extra-vars='env=${var.environment}'"
    working_dir = "../../ansible"

    environment {
      ANSIBLE_CONFIG = "./ansible.cfg"
    }
  }

  provisioner "local-exec" {
    command     = "environments/${var.environment}/gce.py --refresh-cache >/dev/null 2>&1"
    working_dir = "../../ansible"
  }

  provisioner "local-exec" {
    command     = "ansible-playbook --private-key ${var.private_key_path} --tags='awx_wrapper_configure,autoheal_configure' playbooks/mgmt_host.yml --extra-vars='awx_wrapper_cli_host=http://{{ ansible_ssh_host }}'"
    working_dir = "../../ansible"

    environment {
      ANSIBLE_CONFIG = "./ansible.cfg"
    }
  }

  connection {
    type        = "ssh"
    user        = "mgmt-user"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_web" {
  name    = "allow-http-mgmt-${terraform.workspace}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mgmt-host"]
}

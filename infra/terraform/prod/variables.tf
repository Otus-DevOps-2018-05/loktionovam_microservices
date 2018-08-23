variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable docker_host_disk_image {
  description = "Disk image"
}

variable "source_ranges" {
  description = "Allowed ssh source ip"
  type        = "list"
}

variable "count" {
  default = 1
}

variable "size" {
  default = 10
}

variable "app_provision_enabled" {
  description = "Enable/disable reddit app provision switch"
  default     = true
}

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

variable cluster_name {
  description = "Cluster name"
  default     = "cluster-1"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}

variable size {
  description = "Boot disk size"
  default     = 20
}

variable "nodes_count" {
  description = "Cluster nodes count"
  default     = 2
}

variable "min_master_version" {
  description = "The minimum version of the master"
  default     = "1.9.7-gke.6"
}

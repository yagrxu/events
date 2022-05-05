variable cluster_name {
  type = string
}

variable cluster_enabled_log_types {
  type = list(string)
  default = []
}

variable cluster_tags {
  type = map
  default = {}
}

variable tags {
  type = map
  default = {}
}

variable cluster_security_group_id {
  type = list(string)
  default = []
}

variable cluster_version {
  type = string
  default = "1.21"
}

variable cluster_endpoint_private_access {
  type = bool
  default = false
}

variable cluster_endpoint_public_access {
  type = bool
  default = true
}

variable cluster_endpoint_public_access_cidrs {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable subnet_ids {
  type = list(string)
}

variable cluster_ip_family {
  type = string
  default = "ipv4"
}

variable cluster_service_ipv4_cidr {
  type = string
  default = "172.16.0.0/16"
}

variable cluster_timeouts {
  type = map
  default = {}
}

variable node_group_name {
  type = string
}

variable node_group_desired_size {
  type = number
  default = 2
}

variable node_group_min_size {
  type = number
  default = 1
}

variable node_group_max_size {
  type = number
  default = 4
}

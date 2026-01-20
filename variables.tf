variable "project_name" {
  type        = string
  description = "Name of the project to be used as prefix for all resources"
}

variable "cidr_v4" {
  type        = string
  description = "The CIDR block for the network"
  default     = "10.10.0.0/16"
}

variable "region" {
  type        = string
  description = "The region of the resources"
  default     = "nyc1"
}

variable "network_id" {
  type        = string
  description = "Network id if already exists, to override network created by module, it is only for kubernetes cluster resource, for override network on databases and/or instances use their own object inner variable"
  default     = ""
}

variable "firewall_id" {
  type        = string
  description = "Network id if already exists, to override firewall created by module, it is only for kubernetes cluster resource for override firewall on databases and/or instances use their own object inner variable"
  default     = ""
}

variable "create_network" {
  type        = bool
  description = "create or not a new network"
  default     = true
}

variable "network_name" {
  type        = string
  description = "name for the network"
  default     = ""
}

variable "create_firewall" {
  type        = bool
  description = "create or not a firewall"
  default     = true
}

variable "firewall_name" {
  type        = string
  description = "name for the firewall"
  default     = ""
}

variable "firewall_create_default_rules" {
  type        = bool
  description = "Whether create or not default firewall rules, needs to be false when custom rules are needed"
  default     = true
}

variable "firewall_rules" {
  description = "Ingress and egress rules for the firewall"
  type = object({
    ingress = list(object({
      label      = string
      protocol   = string
      port_range = optional(string)
      cidr       = list(string)
      action     = string
    }))
    egress = list(object({
      label      = string
      protocol   = string
      port_range = optional(string)
      cidr       = list(string)
      action     = string
    }))
  })

  default = {
    ingress = [
      {
        label      = "http"
        protocol   = "tcp"
        port_range = "80"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      },
      {
        label      = "https"
        protocol   = "tcp"
        port_range = "443"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      }
    ]

    egress = [
      {
        label      = "all-outbound"
        protocol   = "tcp"
        port_range = "1-65535"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      }
    ]
  }
}

variable "create_cluster" {
  type        = bool
  description = "crate or not the kubernetes cluster in case you only need network and/or firewall"
  default     = true
}

variable "cluster_type" {
  type        = string
  description = "The type of cluster to create, valid options are k3s or talos the default is k3s"
  default     = "k3s"
}

variable "kubernetes_version" {
  type        = string
  description = "The version of k3s to install (optional, the default is currently the latest stable available)"
  default     = "1.30.5-k3s1"
}

variable "cni" {
  type        = string
  description = "The cni for the k3s to install (the default is flannel) valid options are cilium or flannel"
  default     = "flannel"
}

variable "write_kubeconfig" {
  type        = bool
  description = "(false by default) when set to true, kubeconfig is saved to the terraform state file"
  default     = false
}

variable "create_local_kubeconfig" {
  type        = bool
  description = "Whether create or not a local kubeconfig file on /tmp folder"
  default     = false
}

variable "default_pool_size" {
  type        = string
  description = "Size of the nodes in the default nodepool."
  default     = "g4s.kube.xsmall"
}

variable "default_node_count" {
  type        = number
  description = "Number of nodes in the nodepool"
  default     = 3
}

variable "default_pool_labels" {
  type        = map(string)
  default     = {}
  description = "Map of string to identify resources"
}

variable "default_pool_taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default     = []
  description = "taints for default pool nodes"
}

variable "create_node_pools" {
  description = "Whether to create node pools"
  type        = bool
  default     = false
}

variable "node_pools" {
  description = "Definition of Kubernetes node pools to create"
  type = map(object({
    size       = string
    node_count = number
    labels     = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))

  default = {}
}

variable "create_reserved_ip" {
  type        = bool
  description = "Wheter or not create a reserved ip address"
  default     = false
}

variable "create_databases" {
  type        = bool
  description = "Wheter or not create a reserved ip address"
  default     = false
}

variable "databases" {
  description = "Set of database configurations"
  type = set(object({
    name        = string
    size        = string
    nodes       = number
    engine      = string
    version     = string
    network_id  = optional(string)
    firewall_id = optional(string)
  }))
  default = [
    {
      name    = "custom_database"
      size    = "g3.k3s.small"
      nodes   = 2
      engine  = "mysql"
      version = "8.0"
    },
    {
      name    = "analytics_db"
      size    = "g3.k3s.medium"
      nodes   = 3
      engine  = "postgresql"
      version = "14"
    }
  ]
}

variable "create_object_stores" {
  type        = bool
  description = "Wheter or not create object_stores"
  default     = false
}

variable "object_stores" {
  description = "Set of object_stores configurations, for store_credential_name the credential must exist with that name in civo to be used as access key id of an object store"
  type = set(object({
    name            = string
    size_gb         = optional(string)
    region          = optional(string)
    credential_name = optional(string)
  }))
  default = [
    {
      name    = "mystore"
      size_gb = "500"
      region  = "nyc1"
    }
  ]
}

variable "create_instances" {
  type        = bool
  description = "Whether or not create instances"
  default     = false
}

variable "create_sshkey" {
  type        = bool
  description = "Whether or not create sshkeys"
  default     = false
}

variable "create_instances_reserved_ips" {
  type        = bool
  description = "Whether or not create reserved public IPs for instances"
  default     = false
}

variable "instances" {
  description = "Set of instances configurations"
  type = set(object({
    hostname       = string
    tags           = optional(list(string))
    notes          = optional(string)
    size           = string
    disk_image     = string
    initial_user   = optional(string)
    volume_type    = optional(string)
    region         = optional(string)
    write_password = optional(bool)
    sshkey_name    = optional(string)
    sshkey_path    = optional(string)
    network_id     = optional(string)
    firewall_id    = optional(string)
    script_path    = optional(string)
  }))
  default = [
    {
      hostname   = "my-civo-instance"
      tags       = ["nonprod", "my-instance"]
      notes      = "this is an instance"
      size       = "g4s.medium"
      disk_image = "ubuntu-noble"
    }
  ]
}


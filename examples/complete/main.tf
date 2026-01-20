# civo infra
#
module "this" {

  source = "../../"

  project_name = "example"

  cidr_v4 = "10.20.0.0/22"

  default_pool_size  = "g4s.kube.xsmall"
  default_node_count = 2

  create_node_pools = true
  node_pools = {
    "pool_a" = {
      size       = "g4s.kube.small"
      node_count = 3
      labels = {
        "env"  = "dev"
        "role" = "backend"
      }
    }
    "pool_b" = {
      size       = "g4s.kube.medium"
      node_count = 2
      taints = [
        {
          key    = "special"
          value  = "true"
          effect = "NoSchedule"
        }
      ]
    }
  }

  firewall_create_default_rules = false

  firewall_rules = {
    ingress = [
      {
        label      = "All UDP ports open"
        protocol   = "udp"
        port_range = "1-65535"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      },
      {
        label      = "All TCP ports open"
        protocol   = "udp"
        port_range = "1-65535"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      },
    ]
    egress = [
      {
        label      = "All UDP ports open"
        protocol   = "udp"
        port_range = "1-65535"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      },
      {
        label      = "All TCP ports open"
        protocol   = "udp"
        port_range = "1-65535"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      },
      {
        label      = "Ping/traceroute"
        protocol   = "icmp"
        port_range = "1-65535"
        cidr       = ["0.0.0.0/0"]
        action     = "allow"
      }
    ]
  }

  create_reserved_ip = true

  create_databases = true

  databases = [
    {
      name    = "myexampledb"
      size    = "g3.db.small"
      nodes   = "1"
      engine  = "MySQL"
      version = "8.0"
    }
  ]

  create_object_stores = true

  object_stores = [
    {
      name    = "civo-some-unique-object-store-name-888"
      size_gb = "500"
    },
    {
      name            = "civo-some-unique-object-store-name-888"
      size_gb         = "600"
      credential_name = "civo-some-unique-object-store-credential-name"
    }
  ]
}

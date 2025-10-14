# civo infra
#
module "this" {
  source = "../../"

  project_name = "example"

  cidr_v4 = "10.20.0.0/22"

  default_pool_size  = "g4s.kube.xsmall"
  default_node_count = 2
}


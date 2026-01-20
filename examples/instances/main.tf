# civo infra
#
module "this" {

  source = "../../"

  project_name = "example"

  cidr_v4 = "10.20.0.0/22"

  # Set this as false in case you don't want to create a cluster and its network and instead 
  # use specific network ids and firewall ids for your instances
  create_cluster  = false
  create_network  = false
  create_firewall = false

  create_instances = true

  create_sshkey                 = false
  create_instances_reserved_ips = false

  instances = [
    {
      hostname     = "test"
      tags         = ["nonprod"]
      notes        = "test instance"
      size         = "g4s.small"
      disk_image   = "ubuntu-noble"
      initial_user = "civo"
      sshkey_name  = "mykey"             # if not specified module will create it as default-hostname
      sshkey_path  = "~/.ssh/id_rsa.pub" # if not specified it will use default path ~/.ssh/id_rsa.pub
      network_id   = "<some network id (UUID)>"
      firewall_id  = "<some firewall id (UUID)>"
      script_path  = "../../scripting/shell/hello-world.sh"
    },
    {
      hostname       = "test2"
      tags           = ["nonprod"]
      notes          = "test instance 2"
      size           = "g4s.medium"
      disk_image     = "ubuntu-noble"
      initial_user   = "civo"
      write_password = true
      network_id     = "<some network id (UUID)>"
      firewall_id    = "<some firewall id (UUID)>"
    }
  ]
}


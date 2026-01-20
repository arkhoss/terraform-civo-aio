# Custom Module for CIVO

resource "civo_network" "this" {
  count   = var.create_network ? 1 : 0
  label   = var.network_name == "" ? "${var.project_name}-network" : var.network_name
  cidr_v4 = var.cidr_v4
}

resource "civo_firewall" "this" {
  count      = var.create_firewall ? 1 : 0
  name       = var.firewall_name == "" ? "${var.project_name}-firewall" : var.firewall_name
  network_id = length(var.network_id) == 0 ? civo_network.this[0].id : var.network_id

  create_default_rules = var.firewall_create_default_rules

  dynamic "ingress_rule" {
    for_each = var.firewall_create_default_rules ? [] : var.firewall_rules.ingress
    content {
      label      = ingress_rule.value.label
      protocol   = ingress_rule.value.protocol
      port_range = ingress_rule.value.port_range
      cidr       = ingress_rule.value.cidr
      action     = ingress_rule.value.action
    }
  }

  dynamic "egress_rule" {
    for_each = var.firewall_create_default_rules ? [] : var.firewall_rules.egress
    content {
      label      = egress_rule.value.label
      protocol   = egress_rule.value.protocol
      port_range = egress_rule.value.port_range
      cidr       = egress_rule.value.cidr
      action     = egress_rule.value.action
    }
  }
}

resource "civo_kubernetes_cluster" "this" {

  count = var.create_cluster ? 1 : 0

  name   = "${var.project_name}-cluster"
  region = var.region

  firewall_id = length(var.firewall_id) == 0 ? civo_firewall.this[0].id : var.firewall_id
  network_id  = length(var.network_id) == 0 ? civo_network.this[0].id : var.network_id

  cluster_type       = var.cluster_type
  kubernetes_version = var.kubernetes_version
  cni                = var.cni

  write_kubeconfig = var.write_kubeconfig

  pools {
    size       = var.default_pool_size
    node_count = var.default_node_count
    #TODO: (dcaballero) civo provider labels lifecycle seems broken, it walys report back changes even then the label is already applied, needs to create a civo issue
    labels = var.default_pool_labels

    dynamic "taint" {
      for_each = var.default_pool_taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }
  #TODO: (dcaballero) needs to setup autoscaler capability for the module
  # This allows us to make use of cluster autoscaler.
  # If you don't plan to use cluster autoscaler you can remove this `lifecycle` block.
  #     lifecycle {
  #    ignore_changes = [
  #      pools["node_count"],
  #    ]
  #  }
}

resource "civo_kubernetes_node_pool" "pool" {
  for_each = var.create_node_pools ? var.node_pools : {}

  cluster_id = civo_kubernetes_cluster.this[0].id

  size       = each.value.size
  node_count = each.value.node_count


  labels = lookup(each.value, "labels", {})


  dynamic "taint" {
    for_each = try(each.value.taints, []) != null ? each.value.taints : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}

resource "local_file" "kubeconfig" {
  count    = var.create_local_kubeconfig ? 1 : 0
  filename = "/tmp/${civo_kubernetes_cluster.this[0].name}-kubeconfig"
  content  = civo_kubernetes_cluster.this[0].kubeconfig
}

resource "civo_reserved_ip" "this" {
  count = var.create_reserved_ip ? 1 : 0
  name  = var.project_name
}

resource "civo_database" "this" {
  for_each = var.create_databases ? { for db in var.databases : db.name => db } : {}
  name     = each.value.name
  size     = each.value.size
  nodes    = each.value.nodes
  engine   = each.value.engine
  version  = each.value.version

  network_id  = each.value.network_id == null ? civo_network.this[0].id : each.value.network_id
  firewall_id = each.value.firewall_id == null ? civo_firewall.this[0].id : each.value.firewall_id
}

data "civo_object_store_credential" "this" {
  for_each = var.create_object_stores ? {
    for object_store in var.object_stores :
    object_store.name => object_store
    if object_store.credential_name != null && object_store.credential_name != ""
  } : {}

  name = each.value.credential_name
}

resource "civo_object_store" "this" {
  for_each    = var.create_object_stores ? { for object_store in var.object_stores : object_store.name => object_store } : {}
  name        = each.value.name
  max_size_gb = each.value.size_gb
  region      = each.value.region == null ? var.region : each.value.region
  access_key_id = try(
    data.civo_object_store_credential.this[each.value.name].access_key_id,
    null
  )
}


data "civo_disk_image" "this" {
  for_each = var.create_instances ? { for ins in var.instances : ins.hostname => ins } : {}
  filter {
    key    = "name"
    values = [each.value.disk_image]
  }
}

resource "civo_ssh_key" "this" {
  for_each   = var.create_instances && var.create_sshkey ? { for ins in var.instances : ins.hostname => ins } : {}
  name       = each.value.sshkey_name != null ? each.value.sshkey_name : "default-${each.value.hostname}"
  public_key = each.value.sshkey_path != null ? file("${each.value.sshkey_path}") : file("~/.ssh/id_rsa.pub")
}

resource "civo_reserved_ip" "this_instances" {
  for_each = var.create_instances && var.create_instances_reserved_ips ? { for ins in var.instances : ins.hostname => ins } : {}
  name     = each.value.hostname
}

resource "civo_instance" "this" {
  for_each       = var.create_instances ? { for ins in var.instances : ins.hostname => ins } : {}
  hostname       = each.value.hostname
  size           = each.value.size
  disk_image     = element(data.civo_disk_image.this[each.value.hostname].diskimages, 0).id
  notes          = each.value.notes == "" ? "" : each.value.notes
  tags           = each.value.tags == [] ? [] : each.value.tags
  initial_user   = each.value.initial_user == "" ? "civo" : each.value.initial_user
  region         = each.value.region == null ? var.region : each.value.region
  volume_type    = each.value.volume_type == null ? "standard" : each.value.volume_type
  sshkey_id      = ((each.value.sshkey_path != "") && (var.create_sshkey)) ? civo_ssh_key.this[each.value.hostname].id : null
  write_password = each.value.write_password == null ? false : each.value.write_password
  script         = each.value.script_path != null ? file("${each.value.script_path}") : null

  network_id  = each.value.network_id == null ? civo_network.this[0].id : each.value.network_id
  firewall_id = each.value.firewall_id == null ? civo_firewall.this[0].id : each.value.firewall_id
}

resource "civo_instance_reserved_ip_assignment" "this" {
  for_each       = var.create_instances && var.create_instances_reserved_ips ? { for ins in var.instances : ins.hostname => ins } : {}
  instance_id    = civo_instance.this[each.value.hostname].id
  reserved_ip_id = civo_reserved_ip.this_instances[each.value.hostname].id
}


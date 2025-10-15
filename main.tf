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
  #  for_each = var.create_databases ? var.databases : []
  for_each = var.create_databases ? { for db in var.databases : db.name => db } : {}
  name     = each.value.name
  size     = each.value.size
  nodes    = each.value.nodes
  engine   = each.value.engine
  version  = each.value.version

  network_id  = length(var.network_id) == 0 ? civo_network.this[0].id : var.network_id
  firewall_id = length(var.firewall_id) == 0 ? civo_firewall.this[0].id : var.firewall_id
}


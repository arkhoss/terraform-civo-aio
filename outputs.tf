output "network_id" {
  value       = var.create_network ? try(civo_network.this[0].id, null) : null
  description = "network id"
}

output "firewall_id" {
  value       = var.create_firewall ? try(civo_firewall.this[0].id, null) : null
  description = "firewall id"
}

output "cluster_name" {
  value       = var.create_cluster ? try(civo_kubernetes_cluster.this[0].name, null) : null
  description = "The name of the Kubernetes cluster"
}

output "cluster_api_endpoint" {
  value       = var.create_cluster ? try(civo_kubernetes_cluster.this[0].api_endpoint, null) : null
  description = "The API endpoint of the Kubernetes cluster"
}

output "cluster_kubeconfig" {
  value       = var.create_cluster ? try(civo_kubernetes_cluster.this[0].kubeconfig, null) : null
  description = "The KubeConfig for the Kubernetes cluster"
  sensitive   = true
}

output "reserved_ip" {
  value       = var.create_reserved_ip ? try(civo_reserved_ip.this[0].ip, null) : null
  description = "A reserved IP address to be used by an ingress controller or similar"
}

output "database_info" {
  description = "Details of all created Civo databases"
  sensitive   = true
  value = var.create_databases && length(civo_database.this) > 0 ? {
    for name, db in civo_database.this :
    name => {
      id           = db.id
      name         = db.name
      dns_endpoint = db.dns_endpoint
      endpoint     = db.endpoint
      private_ipv4 = db.private_ipv4
    }
  } : {}
}


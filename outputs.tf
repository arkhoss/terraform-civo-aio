output "network_id" {
  value       = civo_network.this[0].id
  description = "network id"
}

output "firewall_id" {
  value       = civo_firewall.this[0].id
  description = "firewall id"
}

output "cluster_name" {
  value       = civo_kubernetes_cluster.this[0].name
  description = "The name of the Kubernetes cluster"
}

output "cluster_api_endpoint" {
  value       = civo_kubernetes_cluster.this[0].api_endpoint
  description = "The API endpoint of the Kubernetes cluster"
}

output "cluster_kubeconfig" {
  value       = civo_kubernetes_cluster.this[0].kubeconfig
  description = "The KubeConfig for the Kubernetes cluster"
  sensitive   = true
}

output "reserved_ip" {
  value       = civo_reserved_ip.this[0].ip
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


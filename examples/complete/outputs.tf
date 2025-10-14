output "cluster_name" {
  value       = module.this.cluster_name
  description = "The name of the Kubernetes cluster"
}

output "cluster_api_endpoint" {
  value       = module.this.cluster_api_endpoint
  description = "The API endpoint of the Kubernetes cluster"
}

output "cluster_kubeconfig" {
  value       = module.this.cluster_kubeconfig
  description = "The KubeConfig for the Kubernetes cluster"
  sensitive   = true
}

output "reserved_ip" {
  value       = module.this.reserved_ip
  description = "The KubeConfig for the Kubernetes cluster"
}

output "database_info" {
  description = "Details of all created Civo databases"
  value       = module.this.database_info
}


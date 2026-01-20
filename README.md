## About
This base module creates all resources for CIVO terraform provider.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.9.6 |
| <a name="requirement_civo"></a> [civo](#requirement_civo) | >= 1.1.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_civo"></a> [civo](#provider_civo) | 1.1.7 |
| <a name="provider_local"></a> [local](#provider_local) | 2.5.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [civo_database.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/database) | resource |
| [civo_firewall.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/firewall) | resource |
| [civo_instance.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/instance) | resource |
| [civo_instance_reserved_ip_assignment.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/instance_reserved_ip_assignment) | resource |
| [civo_kubernetes_cluster.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/kubernetes_cluster) | resource |
| [civo_kubernetes_node_pool.pool](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/kubernetes_node_pool) | resource |
| [civo_network.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/network) | resource |
| [civo_object_store.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/object_store) | resource |
| [civo_reserved_ip.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/reserved_ip) | resource |
| [civo_reserved_ip.this_instances](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/reserved_ip) | resource |
| [civo_ssh_key.this](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/ssh_key) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [civo_disk_image.this](https://registry.terraform.io/providers/civo/civo/latest/docs/data-sources/disk_image) | data source |
| [civo_object_store_credential.this](https://registry.terraform.io/providers/civo/civo/latest/docs/data-sources/object_store_credential) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_v4"></a> [cidr_v4](#input_cidr_v4) | The CIDR block for the network | `string` | `"10.10.0.0/16"` | no |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | The type of cluster to create, valid options are k3s or talos the default is k3s | `string` | `"k3s"` | no |
| <a name="input_cni"></a> [cni](#input_cni) | The cni for the k3s to install (the default is flannel) valid options are cilium or flannel | `string` | `"flannel"` | no |
| <a name="input_create_cluster"></a> [create_cluster](#input_create_cluster) | crate or not the kubernetes cluster in case you only need network and/or firewall | `bool` | `true` | no |
| <a name="input_create_databases"></a> [create_databases](#input_create_databases) | Wheter or not create a reserved ip address | `bool` | `false` | no |
| <a name="input_create_firewall"></a> [create_firewall](#input_create_firewall) | create or not a firewall | `bool` | `true` | no |
| <a name="input_create_instances"></a> [create_instances](#input_create_instances) | Whether or not create instances | `bool` | `false` | no |
| <a name="input_create_instances_reserved_ips"></a> [create_instances_reserved_ips](#input_create_instances_reserved_ips) | Whether or not create reserved public IPs for instances | `bool` | `false` | no |
| <a name="input_create_local_kubeconfig"></a> [create_local_kubeconfig](#input_create_local_kubeconfig) | Whether create or not a local kubeconfig file on /tmp folder | `bool` | `false` | no |
| <a name="input_create_network"></a> [create_network](#input_create_network) | create or not a new network | `bool` | `true` | no |
| <a name="input_create_node_pools"></a> [create_node_pools](#input_create_node_pools) | Whether to create node pools | `bool` | `false` | no |
| <a name="input_create_object_stores"></a> [create_object_stores](#input_create_object_stores) | Wheter or not create object_stores | `bool` | `false` | no |
| <a name="input_create_reserved_ip"></a> [create_reserved_ip](#input_create_reserved_ip) | Wheter or not create a reserved ip address | `bool` | `false` | no |
| <a name="input_create_sshkey"></a> [create_sshkey](#input_create_sshkey) | Whether or not create sshkeys | `bool` | `false` | no |
| <a name="input_databases"></a> [databases](#input_databases) | Set of database configurations | ```set(object({ name = string size = string nodes = number engine = string version = string network_id = optional(string) firewall_id = optional(string) }))``` | ```[ { "engine": "mysql", "name": "custom_database", "nodes": 2, "size": "g3.k3s.small", "version": "8.0" }, { "engine": "postgresql", "name": "analytics_db", "nodes": 3, "size": "g3.k3s.medium", "version": "14" } ]``` | no |
| <a name="input_default_node_count"></a> [default_node_count](#input_default_node_count) | Number of nodes in the nodepool | `number` | `3` | no |
| <a name="input_default_pool_labels"></a> [default_pool_labels](#input_default_pool_labels) | Map of string to identify resources | `map(string)` | `{}` | no |
| <a name="input_default_pool_size"></a> [default_pool_size](#input_default_pool_size) | Size of the nodes in the default nodepool. | `string` | `"g4s.kube.xsmall"` | no |
| <a name="input_default_pool_taints"></a> [default_pool_taints](#input_default_pool_taints) | taints for default pool nodes | ```list(object({ key = string value = string effect = string }))``` | `[]` | no |
| <a name="input_firewall_create_default_rules"></a> [firewall_create_default_rules](#input_firewall_create_default_rules) | Whether create or not default firewall rules, needs to be false when custom rules are needed | `bool` | `true` | no |
| <a name="input_firewall_id"></a> [firewall_id](#input_firewall_id) | Network id if already exists, to override firewall created by module, it is only for kubernetes cluster resource for override firewall on databases and/or instances use their own object inner variable | `string` | `""` | no |
| <a name="input_firewall_name"></a> [firewall_name](#input_firewall_name) | name for the firewall | `string` | `""` | no |
| <a name="input_firewall_rules"></a> [firewall_rules](#input_firewall_rules) | Ingress and egress rules for the firewall | ```object({ ingress = list(object({ label = string protocol = string port_range = optional(string) cidr = list(string) action = string })) egress = list(object({ label = string protocol = string port_range = optional(string) cidr = list(string) action = string })) })``` | ```{ "egress": [ { "action": "allow", "cidr": [ "0.0.0.0/0" ], "label": "all-outbound", "port_range": "1-65535", "protocol": "tcp" } ], "ingress": [ { "action": "allow", "cidr": [ "0.0.0.0/0" ], "label": "http", "port_range": "80", "protocol": "tcp" }, { "action": "allow", "cidr": [ "0.0.0.0/0" ], "label": "https", "port_range": "443", "protocol": "tcp" } ] }``` | no |
| <a name="input_instances"></a> [instances](#input_instances) | Set of instances configurations, sshkey_name if not specified module will create it as default-hostname, sshkey_path if not specified it will use default path ~/.ssh/id_rsa.pub, if network id and/or firewall_id are not specified the module will try to use default network and default firewall ids from the module, this will throw and exception if create_firewall and/or create_network are set to false | ```set(object({ hostname = string tags = optional(list(string)) notes = optional(string) size = string disk_image = string initial_user = optional(string) volume_type = optional(string) region = optional(string) write_password = optional(bool) sshkey_name = optional(string) sshkey_path = optional(string) network_id = optional(string) firewall_id = optional(string) script_path = optional(string) }))``` | ```[ { "disk_image": "ubuntu-noble", "hostname": "my-civo-instance", "notes": "this is an instance", "size": "g4s.medium", "tags": [ "nonprod", "my-instance" ] } ]``` | no |
| <a name="input_kubernetes_version"></a> [kubernetes_version](#input_kubernetes_version) | The version of k3s to install (optional, the default is currently the latest stable available) | `string` | `"1.30.5-k3s1"` | no |
| <a name="input_network_id"></a> [network_id](#input_network_id) | Network id if already exists, to override network created by module, it is only for kubernetes cluster resource, for override network on databases and/or instances use their own object inner variable | `string` | `""` | no |
| <a name="input_network_name"></a> [network_name](#input_network_name) | name for the network | `string` | `""` | no |
| <a name="input_node_pools"></a> [node_pools](#input_node_pools) | Definition of Kubernetes node pools to create | ```map(object({ size = string node_count = number labels = optional(map(string)) taints = optional(list(object({ key = string value = string effect = string }))) }))``` | `{}` | no |
| <a name="input_object_stores"></a> [object_stores](#input_object_stores) | Set of object_stores configurations, for store_credential_name the credential must exist with that name in civo to be used as access key id of an object store | ```set(object({ name = string size_gb = optional(string) region = optional(string) credential_name = optional(string) }))``` | ```[ { "name": "mystore", "region": "nyc1", "size_gb": "500" } ]``` | no |
| <a name="input_project_name"></a> [project_name](#input_project_name) | Name of the project to be used as prefix for all resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | The region of the resources | `string` | `"nyc1"` | no |
| <a name="input_write_kubeconfig"></a> [write_kubeconfig](#input_write_kubeconfig) | (false by default) when set to true, kubeconfig is saved to the terraform state file | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_api_endpoint"></a> [cluster_api_endpoint](#output_cluster_api_endpoint) | The API endpoint of the Kubernetes cluster |
| <a name="output_cluster_kubeconfig"></a> [cluster_kubeconfig](#output_cluster_kubeconfig) | The KubeConfig for the Kubernetes cluster |
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name) | The name of the Kubernetes cluster |
| <a name="output_database_info"></a> [database_info](#output_database_info) | Details of all created Civo databases |
| <a name="output_firewall_id"></a> [firewall_id](#output_firewall_id) | firewall id |
| <a name="output_network_id"></a> [network_id](#output_network_id) | network id |
| <a name="output_reserved_ip"></a> [reserved_ip](#output_reserved_ip) | A reserved IP address to be used by an ingress controller or similar |
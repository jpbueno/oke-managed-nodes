# OKE Cluster with Kubernetes API in Public Subnet (VCN Native)
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  vcn_id             = var.vcn_id
  kubernetes_version = var.kubernetes_version
  name               = "oke-dev-cluster"
  type               = var.cluster_type
  cluster_pod_network_options {
    cni_type = var.cni_type
  }

  endpoint_config {
    is_public_ip_enabled = "true"
    nsg_ids = []
    subnet_id = var.api_public_subnet_id
  }

  options {
    service_lb_subnet_ids = [var.lb_public_subnet_id]
    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }
  }
}

# Node Pool with Worker Nodes in Private Subnet (VCN Native)
resource "oci_containerengine_node_pool" "oke_node_pool" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  kubernetes_version = var.kubernetes_version
  name               = "oke-dev-node-pool"
  node_shape         = var.node_shape
  node_shape_config {
    memory_in_gbs = var.node_memory_gbs
    ocpus         = var.node_ocpus
  }

  node_source_details {
    source_type = "image"
    image_id    = var.image_id
  }

  node_config_details {
    node_pool_pod_network_option_details {
      cni_type = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [var.pod_subnet_id]  # Add the pod subnet IDs here
    }
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.private_subnet_id
    }
    size = var.node_count
  }
}

# Outputs
output "oke_cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.id
}

output "oke_node_pool_id" {
  value = oci_containerengine_node_pool.oke_node_pool.id
}

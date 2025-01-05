# OKE Cluster with Kubernetes API in Public Subnet (VCN Native)
resource "oci_containerengine_cluster" "oke_cluster_managed" {
  compartment_id     = var.compartment_id
  vcn_id             = var.vcn_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  type               = var.cluster_type

  cluster_pod_network_options {
    cni_type = var.cni_type
  }

  endpoint_config {
    is_public_ip_enabled = true
    nsg_ids              = []
    subnet_id            = var.api_public_subnet_id
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
resource "oci_containerengine_node_pool" "oke_managed_node_pool" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.oke_cluster_managed.id
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
      cni_type     = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [var.pod_subnet_id] 
    }
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.private_subnet_id
    }
    size = var.node_count
  }
}

# Add-ons
resource "oci_containerengine_addon" "certmanager_addon" {
  addon_name = "CertManager"
  cluster_id = oci_containerengine_cluster.oke_cluster_managed.id
  remove_addon_resources_on_delete = true
}

resource "oci_containerengine_addon" "clusterautoscaler_addon" {
  addon_name = "ClusterAutoscaler"
  cluster_id = oci_containerengine_cluster.oke_cluster_managed.id
  configurations {
    key   = "nodes"
    value = "3:10:${oci_containerengine_node_pool.oke_managed_node_pool.id}"
  }
  remove_addon_resources_on_delete = true
}

resource "oci_containerengine_addon" "metricsserver_addon" {
  addon_name = "KubernetesMetricsServer"
  cluster_id = oci_containerengine_cluster.oke_cluster_managed.id
  remove_addon_resources_on_delete = true
  depends_on = [oci_containerengine_addon.certmanager_addon]
}

resource "oci_containerengine_addon" "nativeingress_addon" {
  addon_name = "NativeIngressController"
  cluster_id = oci_containerengine_cluster.oke_cluster_managed.id
  configurations {
    key   = "compartmentId"
    value = var.compartment_id
  }
  configurations {
    key   = "loadBalancerSubnetId"
    value = var.lb_public_subnet_id
  }
  remove_addon_resources_on_delete = true
}

# Dynamic Group for Virtual Nodes
resource "oci_identity_dynamic_group" "virtual_nodes_dynamic_group" {
  compartment_id = var.tenancy_id
  name           = "virtual-nodes-dynamic-group"
  description    = "Dynamic group for virtual nodes"

  matching_rule = <<EOF
ALL {resource.type = 'virtualnode'}
EOF
}

# IAM Policy for Virtual Nodes
resource "oci_identity_policy" "virtual_nodes_policy" {
  compartment_id = var.tenancy_id
  name           = "virtual-nodes-policy"
  description    = "Policy for virtual nodes to operate in the specified compartment"

  statements = [
    "Allow dynamic-group virtual-nodes-dynamic-group to manage instance-family in compartment ${var.compartment_name} where ALL {request.principal.type='virtualnode', request.operation='CreateContainerInstance', request.principal.subnet=target.subnet.id}",
    "Allow dynamic-group virtual-nodes-dynamic-group to manage vnics in compartment ${var.compartment_name} where ALL {request.principal.type='virtualnode', request.operation='CreateContainerInstance', request.principal.subnet=target.subnet.id}",
    "Allow dynamic-group virtual-nodes-dynamic-group to manage network-security-group in compartment ${var.compartment_name} where ALL {request.principal.type='virtualnode', request.operation='CreateContainerInstance'}"
  ]
}

# Outputs
output "oke_cluster_managed_id" {
  value = oci_containerengine_cluster.oke_cluster_managed.id
}

output "oke_managed_node_pool_id" {
  value = oci_containerengine_node_pool.oke_managed_node_pool.id
}

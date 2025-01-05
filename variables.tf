variable "tenancy_id" {
  description = "The OCID of the tenancy root compartment."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "cluster_name" {
  type = string
  description = "The name of the OKE cluster."
}

variable "compartment_name" {
  type = string
  description = "(optional) describe your variable"
}

variable "region" {
  description = "The OCI region where resources will be created."
  type        = string
}

variable "vcn_id" {
  description = "The OCID of the existing VCN to use for the OKE cluster."
  type        = string
}

variable "private_subnet_id" {
  description = "The OCID of the existing private subnet for worker nodes in the OKE cluster."
  type        = string
}

variable "lb_public_subnet_id" {
  description = "The OCID of the existing private subnet for LB."
  type        = string
}

variable "api_public_subnet_id" {
  description = "The OCID of the existing private subnet for API."
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use for the OKE cluster and node pool."
  type        = string
}

variable "cluster_type" {
  description = "Cluster type"
  type = string
  default = "enhanced"
}

variable "node_shape" {
  description = "The shape of the worker nodes in the OKE node pool."
  type        = string
  default     = "VM.Standard.E3.Flex"
}

variable "node_count" {
  description = "The number of worker nodes in the OKE node pool."
  type        = number
  default     = 2
}

variable "image_id" {
  description = "The OCID of the image used to create the nodes."
  type        = string
}

variable "node_ocpus" {
  description = "Number of OCPUs for the flexible shape"
  type        = number
}

variable "node_memory_gbs" {
  description = "Memory in GB for the flexible shape"
  type        = number
}

variable "cni_type" {
  description = "Type of CNI plugin. Module supports 'FLANNEL_OVERLAY' or 'OCI_VCN_IP_NATIVE"
  type = string
  default = "OCI_VCN_IP_NATIVE"
}

variable "pod_subnet_id" {
  description = "The subnet ID where the Kubernetes pods will be placed"
  type        = string
}

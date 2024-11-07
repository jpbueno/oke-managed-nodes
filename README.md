# OKE Managed Nodes

This setup is for a public Oracle Kubernetes Engine (OKE) cluster on Oracle Cloud Infrastructure (OCI), with a Virtual Cloud Network (VCN) configured to use managed node pools for easy scaling and management.

## Features

- **Public OKE Cluster**: Deploys a publicly accessible OKE cluster with secure networking configurations.
- **VCN Configuration**: Native OCI VCN setup with regional subnets for better performance and security.
- **Managed Node Pools**: Uses managed nodes, so you don’t have to worry about node maintenance and scaling.
- **Gateways and Security**:
  - **Internet Gateway**: Provides internet access to public-facing nodes.
  - **NAT Gateway**: Allows private node access for outbound internet traffic.
  - **Service Gateway**: Gives access to OCI services without going over the public internet.
  - **Security Lists**: Predefined security rules to control access to and from the cluster.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- An Oracle Cloud Infrastructure account with permissions to create OKE and networking resources
- Configured OCI CLI credentials for authentication
- **Virtual Cloud Network (VCN)**: You need to set up a VCN before deploying the OKE cluster. You can create one using [oci-base-vcn](https://github.com/jpbueno/oci-base-vcn).

## Usage

Clone this repository, review the configuration, and apply it with Terraform to set up your OKE cluster with managed nodes.

```bash
git clone https://github.com/yourusername/oke-managed-nodes.git
cd oke-managed-nodes
terraform init
terraform apply

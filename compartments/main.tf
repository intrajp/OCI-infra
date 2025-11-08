# 1. compartment for infra (Network, Compute, LB, DNS, IAM... )
resource "oci_identity_compartment" "infra_compartment" {
  compartment_id = var.tenancy_ocid # Under the tenancy
  name           = var.infra_compartment_name
  description    = "Compartment for core infrastructure (VCN, Compute, LB)"
}

# 2. compartment for RAG application
resource "oci_identity_compartment" "rag_compartment" {
  compartment_id = var.tenancy_ocid
  name           = var.rag_compartment_name
  description    = "Compartment for RAG AI Application"
}

# 3. compartment for OKE application
resource "oci_identity_compartment" "oke_compartment" {
  compartment_id = var.tenancy_ocid
  name           = var.oke_compartment_name
  description    = "Compartment for Kubernetes (OKE) Application"
}

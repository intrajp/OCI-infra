# --- For provider (use in provider.tf) ---
variable "tenancy_ocid" {
  description = "OCI tenency's OCID"
}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "infra_compartment_name" {
  description = "Name for the core infrastructure compartment (network, compute, etc.)"
  default     = "infra_compartment"
}

variable "rag_compartment_name" {
  description = "Name for the RAG AI application compartment"
  default     = "rag_app_compartment"
}

variable "oke_compartment_name" {
  description = "Name for the Kubernetes (OKE) compartment"
  default     = "oke_app_compartment"
}

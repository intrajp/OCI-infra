output "infra_compartment_id" {
  description = "The OCID of the core infrastructure compartment"
  value       = oci_identity_compartment.infra_compartment.id
}

output "rag_compartment_id" {
  description = "The OCID of the RAG application compartment"
  value       = oci_identity_compartment.rag_compartment.id
}

output "oke_compartment_id" {
  description = "The OCID of the OKE application compartment"
  value       = oci_identity_compartment.oke_compartment.id
}

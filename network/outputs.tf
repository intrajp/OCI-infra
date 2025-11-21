output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.my_vcn.id
}

# This should be 'subnet_id'
output "subnet_id" {
  description = "The OCID of the public subnet"
  value       = oci_core_subnet.my_public_subnet.id
}

output "private_subnet_id" {
  description = "The OCID of the private subnet"
  value       = oci_core_subnet.my_private_subnet.id
}

output "rag_subnet_id" {
  description = "The OCID of the RAG private subnet"
  value       = oci_core_subnet.rag_private_subnet.id
}

output "oke_private_subnet_id" {
  description = "The OCID of the OKE private subnet"
  value       = oci_core_subnet.oke_private_subnet.id
}

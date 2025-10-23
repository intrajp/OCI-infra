output "subnet_id" {
  description = "The OCID of the public subnet"
  value       = oci_core_subnet.my_subnet.id
}

output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.my_vcn.id
}

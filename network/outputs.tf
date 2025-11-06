output "subnet_id" {
  description = "The OCID of the public subnet"
  value       = oci_core_subnet.my_subnet.id
}

output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.my_vcn.id
}

output "private_subnet_id" {
  description = "The OCID of the private subnet"
  value       = oci_core_subnet.my_private_subnet.id
}

output "lb_reserved_ip_id" {
  description = "The OCID of the reserved public IP for the LB"
  value       = oci_core_public_ip.my_lb_reserved_ip.id
}

output "lb_reserved_ip_address" {
  description = "The string value of the reserved public IP"
  value       = oci_core_public_ip.my_lb_reserved_ip.ip_address
}

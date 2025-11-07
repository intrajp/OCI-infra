output "private_instance_ip" {
  description = "The private IP of the private instance"
  value       = oci_core_instance.private_instance.private_ip
}
output "public_instance_ip" {
  description = "The prublic IP of the public instance"
  value       = oci_core_instance.public_instance.public_ip
}

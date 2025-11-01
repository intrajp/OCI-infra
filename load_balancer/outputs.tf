output "load_balancer_public_ip" {
  description = "The public IP address of the Load Balancer"
  value       = oci_load_balancer_load_balancer.my_lb.ip_address_details[0].ip_address
}

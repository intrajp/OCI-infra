variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "dns_region" {
  description = "OCI region where the public DNS zone is managed"
  type        = string
  default     = "ap-osaka-1"
}
variable "domain_name" {
  description = "The root domain name to manage in OCI DNS (e.g., letsgopc.net)"
  type        = string
}
variable "web_load_balancer_ip" {
  description = "The public IP address of the active web load balancer"
  type        = string
  default     = "161.33.205.155"
}

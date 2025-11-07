variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "domain_name" {
  description = "The root domain name to manage in OCI DNS (e.g., letsgopc.net)"
  type        = string
}

variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "db_admin_password" {
  description = "ADMIN user's password for Autonomous Database"
  sensitive   = true # This will hide password in plan
}

variable "db_name" {
  description = "Database Name"
  default     = "mydemodb"
}

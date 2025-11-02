# --- For provider.tf ---
variable "tenancy_ocid" {
  description = "OCID for OCI tenancy"
}

variable "user_ocid" {
  description = "OCID for OCI user"
}

variable "fingerprint" {
  description = "Fingerprint for API key"
}

variable "private_key_path" {
  description = "Path for API key"
}

variable "region" {
  description = "OCI region"
}

# --- For main.tf ---
variable "compartment_id" {
  description = "OCID for compartment which the resources shoudl be created"
}

variable "vcn_cidr_block" {
  description = "CIDR block for VCN"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for private subnet"
  default     = "10.0.2.0/24" # This should not overlap with public subnet 
}

variable "source_cidr_for_ssh" {
  description = "IP address for SSH which should be allowed (i.e. Your Global IP/32)"
  default     = "0.0.0.0/0" # This is not recommended.
}

variable "source_cidr_for_http" {
  description = "IP address for HTTP which should be allowed (i.e. Your Global IP/32)"
  default     = "0.0.0.0/0"
}

# 1. Read network tfstate file
data "terraform_remote_state" "network" {
  backend = "oci"
  config = {
    bucket    = "intrajp_oci_certificates"
    namespace = "nrdrpcgfpznz"
    key       = "network/terraform.tfstate" # Refer networ state
    region    = "ap-tokyo-1"
  }
}

# 2. Read compute tfstate file
data "terraform_remote_state" "compute" {
  backend = "oci"
  config = {
    bucket    = "intrajp_oci_certificates"
    namespace = "nrdrpcgfpznz"
    key       = "compute/terraform.tfstate" # Refer compute state
    region    = "ap-tokyo-1"
  }
}

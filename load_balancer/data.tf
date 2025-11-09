# 1. Read network tfstate file
data "terraform_remote_state" "network" {
  backend = "oci"
  config = {
    bucket    = "bucket-20251109-0952"
    namespace = "nrdrpcgfpznz"
    key       = "network/terraform.tfstate" # Refer networ state
    region    = "ap-tokyo-1"
  }
}

# 2. Read compute tfstate file
data "terraform_remote_state" "compute" {
  backend = "oci"
  config = {
    bucket    = "bucket-20251109-0952"
    namespace = "nrdrpcgfpznz"
    key       = "compute/terraform.tfstate" # Refer compute state
    region    = "ap-tokyo-1"
  }
}

# 3. Read dns tfstate file
data "terraform_remote_state" "dns" {
  backend = "oci"
  config = {
    bucket    = "bucket-20251109-0952"
    namespace = "nrdrpcgfpznz"
    key       = "dns/terraform.tfstate" # Refer dns state
    region    = "ap-tokyo-1"
  }
}

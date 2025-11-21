# network/data.tf

# Read compartments state file (tfstate)
data "terraform_remote_state" "compartments" {
  backend = "oci"
  config = {
    bucket    = "bucket-20251111-1910"  # Same bucket name as  network
    namespace = "nrdrpcgfpznz"              # Same namespace as network
    key       = "network/terraform.tfstate" # Designate same state file as network
    region    = "ap-osaka-1"
  }
}

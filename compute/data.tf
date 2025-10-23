data "terraform_remote_state" "network" {
  backend = "oci"

  # Same settigs as network/backend.tf
  config = {
    bucket    = "intrajp_oci_certificates"  # Same bucket name as  network
    namespace = "nrdrpcgfpznz"              # Same namespace as network
    key       = "network/terraform.tfstate" # Designate same state file as network
    region    = "ap-tokyo-1"
  }
}

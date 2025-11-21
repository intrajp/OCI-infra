data "terraform_remote_state" "network" {
  backend = "oci"
  # Same settigs as network/backend.tf
  config = {
    #bucket    = "bucket-20251109-0952"  # Same bucket name as  network
    bucket    = "bucket-20251111-1910"  # Same bucket name as  network
    namespace = "nrdrpcgfpznz"              # Same namespace as network
    key       = "network/terraform.tfstate" # Designate same state file as network
    #region    = "ap-tokyo-1"
    region    = "ap-osaka-1"
  }
}

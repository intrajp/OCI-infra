# Read load_balancer's state file (tfstate)
data "terraform_remote_state" "load_balancer" {
  backend = "oci"

  config = {
    bucket    = "bucket-20251111-1910"
    namespace = "nrdrpcgfpznz"
    key       = "load_balancer/terraform.tfstate" # refer load_balancer's state
    region    = "ap-osaka-1"
  }
}

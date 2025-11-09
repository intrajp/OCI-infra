# Read load_balancer's state file (tfstate)
data "terraform_remote_state" "load_balancer" {
  backend = "oci"

  config = {
    bucket    = "bucket-20251109-0952"
    namespace = "nrdrpcgfpznz"
    key       = "load_balancer/terraform.tfstate" # refer load_balancer's state
    region    = "ap-tokyo-1"
  }
}

# Read load_balancer's state file (tfstate)
data "terraform_remote_state" "load_balancer" {
  backend = "oci"

  config = {
    bucket    = "intrajp_oci_certificates"
    namespace = "nrdrpcgfpznz"
    key       = "load_balancer/terraform.tfstate" # refer load_balancer's state
    region    = "ap-tokyo-1"
  }
}

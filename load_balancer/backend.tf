terraform {
  backend "oci" {
    namespace = "nrdrpcgfpznz"
    bucket = "bucket-20251111-1910"
    key    = "load_balancer/terraform.tfstate"
    region = "ap-osaka-1"
  }
}

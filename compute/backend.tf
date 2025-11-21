terraform {
  backend "oci" {
    namespace = "nrdrpcgfpznz"
    bucket = "bucket-20251111-1910"
    key    = "compute/terraform.tfstate"
    region = "ap-osaka-1"
  }
}

terraform {
  backend "oci" {
    namespace = "nrdrpcgfpznz"
    #bucket = "bucket-20251109-0952"
    bucket = "bucket-20251111-1910"
    key    = "compartments/terraform.tfstate"
    #region = "ap-tokyo-1"
    region = "ap-osaka-1"
  }
}

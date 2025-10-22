terraform {
  backend "oci" {
    # Save state file into the bucket. This is an example.
    bucket = "intrajp_oci_certificates" 
    # This is the Object storage namespace in your tenancy. This is an example.
    namespace = "nrdrpcgfpznz" 
    # path inside the bucket (file name)
    key = "compute/terraform.tfstate"
    region = "ap-tokyo-1"
  }
}

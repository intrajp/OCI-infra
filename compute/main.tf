terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.22.0"
    }
  }
}

# -------------------------------------------------
# 1. Public Instance (Jump Host)
# -------------------------------------------------
resource "oci_core_instance" "public_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E3.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }
  source_details {
    source_id               = var.image_bastion_id
    source_type             = "image"
    boot_volume_size_in_gbs = 50
    instance_source_image_filter_details {
      compartment_id = var.compartment_id
    }
  }
  preserve_boot_volume = false

  create_vnic_details {
    # Refer Public Subnet
    subnet_id        = data.terraform_remote_state.network.outputs.subnet_id
    assign_public_ip = true
    hostname_label   = "tf-public"
  }
  display_name = "PublicInstance"
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# -------------------------------------------------
# 2. Private Instance (Newly added)
# -------------------------------------------------
resource "oci_core_instance" "private_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 16
  }
  source_details {
    source_id               = var.image_private_id
    source_type             = "image"
    boot_volume_size_in_gbs = 200
    instance_source_image_filter_details {
      compartment_id = var.compartment_id
    }
  }
  preserve_boot_volume = false

  create_vnic_details {
    # Look Private Subnet 
    subnet_id = data.terraform_remote_state.network.outputs.private_subnet_id

    # No Public IP is assigned
    assign_public_ip = false
    hostname_label   = "tf-private"
  }
  display_name = "PrivateInstance"
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

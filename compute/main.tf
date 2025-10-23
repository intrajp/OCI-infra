terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.22.0"
    }
  }
}

# -------------------------------------------------
# Compute Instance
# -------------------------------------------------
resource "oci_core_instance" "test_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }

  source_details {
    source_id               = var.image_id
    source_type             = "image"
    boot_volume_size_in_gbs = 50
    instance_source_image_filter_details {
      compartment_id = var.compartment_id
    }
  }
  preserve_boot_volume = false

  create_vnic_details {
    subnet_id        = data.terraform_remote_state.network.outputs.subnet_id
    assign_public_ip = true
    display_name     = "terraform-vnic"
    hostname_label   = "tfvm"
  }

  display_name = var.instance_display_name

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

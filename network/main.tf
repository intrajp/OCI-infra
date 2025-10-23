# -------------------------------------------------
# 1. VCN (Virtual Cloud Network)
# -------------------------------------------------
resource "oci_core_vcn" "my_vcn" {
  compartment_id = var.compartment_id
  display_name   = "MyVcn"
  cidr_block     = var.vcn_cidr_block # expects "10.0.0.0/16"
  # Designate DNS label to enable DNS in VCN
  dns_label      = "myvcn"
}

# -------------------------------------------------
# 2. Internet Gateway (Needed for Public Subnet)
# -------------------------------------------------
resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyIgw"
}

# -------------------------------------------------
# 3. Route Table (Needed for Public Subnet)
# -------------------------------------------------
resource "oci_core_route_table" "my_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"                         # For internet 
    network_entity_id = oci_core_internet_gateway.my_igw.id # For IGW
  }
}

# -------------------------------------------------
# 4. Security List (Firewall)
# -------------------------------------------------
resource "oci_core_security_list" "my_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MySecurityList"

  # SSH (TCP/22)
  ingress_security_rules {
    protocol = "6"                     # TCP
    source   = var.source_cidr_for_ssh # "0.0.0.0/0" or yourIP/32
    tcp_options {
      max = 22
      min = 22
    }
  }

  # Allow all for egress 
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}


# -------------------------------------------------
# 5. Subnet (Public Subnet)
# -------------------------------------------------
resource "oci_core_subnet" "my_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id # 1. Depends on VCN
  display_name   = "MyPublicSubnet"
  cidr_block     = var.subnet_cidr_block # Expects like "10.0.1.0/24"

  # 3. Connects Route Table
  route_table_id = oci_core_route_table.my_route_table.id

  # 4. Connects Security List
  security_list_ids = [oci_core_security_list.my_security_list.id]

  # For Public Subnet
  prohibit_public_ip_on_vnic = false

  # Designate DNS label to enable DNS in Subnet (Unique in VCN) 
  dns_label      = "tfpublic"
}

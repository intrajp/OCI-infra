# -------------------------------------------------
# 1. VCN (Virtual Cloud Network)
# -------------------------------------------------
resource "oci_core_vcn" "my_vcn" {
  compartment_id = var.compartment_id
  display_name   = "MyVcn"
  cidr_block     = var.vcn_cidr_block # expects "10.0.0.0/16"
  # Designate DNS label to enable DNS in VCN
  dns_label = "myvcn"
}

# -------------------------------------------------
# 2. Data source for Service Gateway (SGW)
# -------------------------------------------------
data "oci_core_services" "all_oci_services" {
  filter {
    name = "name"
    # Match pattern "All ... Services ..."
    values = ["All .* Services"]
    # Enable regular exression
    regex = true
  }
}

# -------------------------------------------------
# 3-1. Internet Gateway (Needed for Public Subnet)
# -------------------------------------------------
resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyIgw"
}

# -------------------------------------------------
# 3-2. NAT Gateway (NGW)
# -------------------------------------------------
resource "oci_core_nat_gateway" "my_nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyNatGateway"
}

# -------------------------------------------------
# 3-3. Service Gateway (SGW)
# -------------------------------------------------
resource "oci_core_service_gateway" "my_service_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyServiceGateway"
  services {
    # Use first element which matched with regular expression
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

# -------------------------------------------------
# 4-1. Public Route Table
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
# 4-2. Private Route Table 
# -------------------------------------------------
resource "oci_core_route_table" "my_private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyPrivateRouteTable"

  route_rules {
    # For Internet -> to NGW
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.my_nat_gateway.id
  }
  route_rules {
    # For OCI Service -> to SGW
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    network_entity_id = oci_core_service_gateway.my_service_gateway.id
  }
}

# -------------------------------------------------
# 5-1. Subnet (Public Subnet)
# -------------------------------------------------
resource "oci_core_subnet" "my_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id # 1. Depends on VCN
  display_name   = "MyPublicSubnet"
  cidr_block     = var.public_subnet_cidr_block # Expects like "10.0.1.0/24"

  # Connects Route Table
  route_table_id = oci_core_route_table.my_route_table.id

  # Connects Security List
  security_list_ids = [oci_core_security_list.my_security_list.id]

  # For Public Subnet
  prohibit_public_ip_on_vnic = false

  # Designate DNS label to enable DNS in Subnet (Unique in VCN) 
  dns_label = "tfpublic"
}

# -------------------------------------------------
# 5-2. Private Subnet 
# -------------------------------------------------
resource "oci_core_subnet" "my_private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyPrivateSubnet"
  cidr_block     = var.private_subnet_cidr_block

  # Connect Private Route Table and Security List
  route_table_id    = oci_core_route_table.my_private_route_table.id
  security_list_ids = [oci_core_security_list.my_private_security_list.id]

  # This is the definition for the Private Subnet
  prohibit_public_ip_on_vnic = true

  # Enable hostname
  dns_label = "tfprivate"
}

# -------------------------------------------------
# 5-3. RAG Private Subnet 
# -------------------------------------------------
resource "oci_core_subnet" "rag_private_subnet" {
  # Refer OCID of RAG compartment from data.compartments
  compartment_id = var.compartment_id
  
  vcn_id         = oci_core_vcn.my_vcn.id # Existing VCN
  display_name   = "RagPrivateSubnet"
  cidr_block     = var.rag_subnet_cidr_block

  # ★ Using same setting as compute/ private subnet
  route_table_id    = oci_core_route_table.my_private_route_table.id
  security_list_ids = [oci_core_security_list.my_private_security_list.id]

  prohibit_public_ip_on_vnic = true
  dns_label                  = "rag"
}

# -------------------------------------------------
# 5-4. OKE Private Subnet 
# -------------------------------------------------
resource "oci_core_subnet" "oke_private_subnet" {
  # Refer OCID of OKE compartment from data.compartments
  compartment_id = var.compartment_id
  
  vcn_id         = oci_core_vcn.my_vcn.id # Existing VCN
  display_name   = "OKEPrivateSubnet"
  cidr_block     = var.oke_subnet_cidr_block

  # ★ Using same setting as compute/ private subnet
  route_table_id    = oci_core_route_table.my_private_route_table.id
  security_list_ids = [oci_core_security_list.my_private_security_list.id]

  prohibit_public_ip_on_vnic = true
  dns_label                  = "oke"
}

# -------------------------------------------------
# 6-1. Public Security List
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

  # Allow HTTP (TCP/80) from the internet (for LB)
  ingress_security_rules {
    protocol    = "6"                      # TCP
    source      = var.source_cidr_for_http # "0.0.0.0/0" or yourIP/32
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 80
      min = 80
    }
  }

  # Allow HTTPS (TCP/443) from the internet (for LB)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 443
      min = 443
    }
  }

  # Allow all for egress 
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# -------------------------------------------------
# 6-2. Private Security List 
# -------------------------------------------------
resource "oci_core_security_list" "my_private_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "MyPrivateSecurityList"

  # Ingress
  ingress_security_rules {
    # VCN (e.g., Only SSH from 10.0.0.0/16)
    protocol    = "6" # TCP
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    # Allow HTTP(80) from the load balancer
    protocol    = "6"                # TCP
    source      = var.vcn_cidr_block # From whole VCN
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 80
      min = 80
    }
  }

  # Allow HTTPS(443) from the Load Balancer
  ingress_security_rules {
    protocol    = "6"                # TCP
    source      = var.vcn_cidr_block # from whole VCN
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 443
      min = 443
    }
  }

  ingress_security_rules {
    # Ping(ICMP) from incide VCN (For Troubleshooting)
    protocol    = "1" # ICMP
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
  }

  ingress_security_rules {
    # Allow connection from App layer(inside VCN) to DB(1522)
    protocol    = "6"                # TCP
    source      = var.vcn_cidr_block # from whole VCN
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 1522
      min = 1522
    }
  }

  # Allow connection to OpenSearch(9200) from VCN
  ingress_security_rules {
    protocol  = "6"                  # TCP
    source    = var.vcn_cidr_block # from whole VCN 
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
      max = 9200
      min = 9200
    }
  }

  # Allow all Egress
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
  }
}

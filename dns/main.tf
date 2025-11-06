# 1. Create a zone （i.e., myawesomeserverce.net）on OCI DNS
resource "oci_dns_zone" "my_zone" {
  compartment_id = var.compartment_id
  name           = var.domain_name
  zone_type      = "PRIMARY"
}

# 2. Create A record (root domain @ -> LB's IP)
resource "oci_dns_rrset" "a_record_root" {
  zone_name_or_id = oci_dns_zone.my_zone.id
  domain          = var.domain_name
  rtype           = "A"

  items {
    domain = var.domain_name
    rtype  = "A"
    ttl    = 300
    rdata  = data.terraform_remote_state.load_balancer.outputs.load_balancer_public_ip
  }
}

# 3. Create A record (www -> LB's IP)
resource "oci_dns_rrset" "a_record_www" {
  zone_name_or_id = oci_dns_zone.my_zone.id
  domain          = "www.${var.domain_name}"
  rtype           = "A"

  items {
    domain = "www.${var.domain_name}"
    rtype  = "A"
    ttl    = 300
    rdata  = data.terraform_remote_state.load_balancer.outputs.load_balancer_public_ip
  }
}

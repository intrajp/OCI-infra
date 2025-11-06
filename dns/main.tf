# 1. OCI DNS にドメイン（letsgopc.net）の管理ゾーンを作成
resource "oci_dns_zone" "my_zone" {
  compartment_id = var.compartment_id
  name           = var.domain_name
  zone_type      = "PRIMARY"
}

# 2. Aレコードを作成（ルートドメイン @ -> LBのIP）
resource "oci_dns_rrset" "a_record_root" {
  zone_name_or_id = oci_dns_zone.my_zone.id
  # --- ↓↓↓ 外側にも必要 ↓↓↓ ---
  domain          = var.domain_name
  rtype           = "A"
  # --- ↑↑↑ 外側ここまで ↑↑↑ ---

  items {
    # --- ↓↓↓ 内側にも必要（これが正解） ↓↓↓ ---
    domain = var.domain_name
    rtype  = "A"
    ttl    = 300
    rdata  = data.terraform_remote_state.load_balancer.outputs.load_balancer_public_ip
    # --- ↑↑↑ 内側ここまで ↑↑↑ ---
  }
}

# 3. Aレコードを作成（www -> LBのIP）
resource "oci_dns_rrset" "a_record_www" {
  zone_name_or_id = oci_dns_zone.my_zone.id
  # --- ↓↓↓ 外側にも必要 ↓↓↓ ---
  domain          = "www.${var.domain_name}"
  rtype           = "A"
  # --- ↑↑↑ 外側ここまで ↑↑↑ ---

  items {
    # --- ↓↓↓ 内側にも必要（これが正解） ↓↓↓ ---
    domain = "www.${var.domain_name}"
    rtype  = "A"
    ttl    = 300
    rdata  = data.terraform_remote_state.load_balancer.outputs.load_balancer_public_ip
    # --- ↑↑↑ 内側ここまで ↑↑↑ ---
  }
}

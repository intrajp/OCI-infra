# -------------------------------------------------
# 1. Load Balancer 
# -------------------------------------------------
resource "oci_load_balancer_load_balancer" "my_lb" {
  compartment_id = var.compartment_id
  display_name   = "MyTerraformLB"
  shape          = "flexible"
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
  subnet_ids = [
    data.terraform_remote_state.network.outputs.subnet_id
  ]
}

# -------------------------------------------------
# 2. Backend set (transfers Nginx's HTTPS port 443)
# -------------------------------------------------
resource "oci_load_balancer_backend_set" "my_backend_set_https" {
  name             = "my-backend-set-https"
  load_balancer_id = oci_load_balancer_load_balancer.my_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = 443
  }
}

# -------------------------------------------------
# 3. Backend set (transfers Nginx's HTTP port 80)
# -------------------------------------------------
resource "oci_load_balancer_backend_set" "my_backend_set_http" {
  name             = "my-backend-set-http"
  load_balancer_id = oci_load_balancer_load_balancer.my_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = 80
  }
}

# -------------------------------------------------
# 4. HTTP listener (port 80) -> TCP protocol
# (Nginx does redirection)
# -------------------------------------------------
resource "oci_load_balancer_listener" "http_listener" {
  name                     = "http-listener"
  load_balancer_id         = oci_load_balancer_load_balancer.my_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.my_backend_set_http.name # set HTTP backend
  port                     = 80
  protocol                 = "TCP" # not "HTTP" but "TCP"
}

# -------------------------------------------------
# 5. HTTPS listener (port 443) -> TCP protocol
# (Nginx takes care of SSL certificate)
# -------------------------------------------------
resource "oci_load_balancer_listener" "https_listener" {
  name                     = "https-listener"
  load_balancer_id         = oci_load_balancer_load_balancer.my_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.my_backend_set_https.name # set HTTPS backend
  port                     = 443
  protocol                 = "TCP" # not "HTTP" but "TCP"
}

# -------------------------------------------------
# 6. Backend (indicates private instance's 443)
# -------------------------------------------------
resource "oci_load_balancer_backend" "my_backend_https" {
  load_balancer_id = oci_load_balancer_load_balancer.my_lb.id
  backendset_name  = oci_load_balancer_backend_set.my_backend_set_https.name
  ip_address       = data.terraform_remote_state.compute.outputs.private_instance_ip
  port             = 443 # port 443
}

# -------------------------------------------------
# 7. Backend (indicates private instance's 80)
# -------------------------------------------------
resource "oci_load_balancer_backend" "my_backend_http" {
  load_balancer_id = oci_load_balancer_load_balancer.my_lb.id
  backendset_name  = oci_load_balancer_backend_set.my_backend_set_http.name
  ip_address       = data.terraform_remote_state.compute.outputs.private_instance_ip
  port             = 80 # port 80
}

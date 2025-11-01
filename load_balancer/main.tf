# 1. Load Balancer (Deployed in Publuc subnet) 
resource "oci_load_balancer_load_balancer" "my_lb" {
  compartment_id = var.compartment_id
  display_name   = "MyTerraformLB"
  shape          = "flexible"

  shape_details {
      minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }

  subnet_ids = [
    # Get public subnet ID from data.network
    data.terraform_remote_state.network.outputs.subnet_id
  ]
}

# 2. Backendset (Group definition to which connection sends)
resource "oci_load_balancer_backend_set" "my_backend_set" {
  name             = "my-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.my_lb.id
  policy           = "ROUND_ROBIN" 

  # Healthcheck (Check if private instance is living)
  health_checker {
    protocol = "HTTP"
    port     = 80     # Web server port of the instance
    url_path = "/"    # Check if 200 OK returns
  }
}

# 3. Listener (Which port LB waits)
resource "oci_load_balancer_listener" "my_listener" {
  name                     = "http-listener"
  load_balancer_id         = oci_load_balancer_load_balancer.my_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.my_backend_set.name
  port                     = 80 # 80 port from the internet
  protocol                 = "HTTP"
}

# 4. Backend
resource "oci_load_balancer_backend" "my_backend" {
  load_balancer_id = oci_load_balancer_load_balancer.my_lb.id
  backendset_name  = oci_load_balancer_backend_set.my_backend_set.name

  # Get Pravate IP from data.compute
  ip_address = data.terraform_remote_state.compute.outputs.private_instance_ip
  
  port = 80 # Web server port in the private subnet
}

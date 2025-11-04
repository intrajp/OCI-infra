resource "oci_database_autonomous_database" "my_adb" {
  compartment_id = var.compartment_id
  display_name   = "MyTerraformADB"
  db_name        = var.db_name

  # Setting to use it cheap 
  is_free_tier             = true # Use free tier (it is best for the test)
  db_workload              = "OLTP"

  # Required password 
  admin_password = var.db_admin_password

  # This prevents destroy database, if you need to destroy, please comment out this block and apply again.
  lifecycle {
    prevent_destroy = true
  }

}

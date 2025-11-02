output "db_connection_strings" {
  description = "Connection strings for the Autonomous Database"
  value       = oci_database_autonomous_database.my_adb.connection_strings
  sensitive   = true
}

output "db_id" {
  description = "The OCID of the Autonomous Database"
  value       = oci_database_autonomous_database.my_adb.id
}

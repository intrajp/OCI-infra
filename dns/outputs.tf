output "oci_nameservers" {
  description = "The OCI nameservers to delegate your domain to. You must set these in your domain registrar (e.g., Squarespace)."
  value       = oci_dns_zone.my_zone.nameservers[*].hostname
}

output "zone_id" {
  description = "The OCID of the primary DNS Zone"
  value       = oci_dns_zone.my_zone.id
}

output "oci_nameservers" {
  description = "The OCI nameservers to delegate your domain to. You must set these in your domain registrar (i.e., Squarespace)."
  value       = oci_dns_zone.my_zone.nameservers[*].hostname
}

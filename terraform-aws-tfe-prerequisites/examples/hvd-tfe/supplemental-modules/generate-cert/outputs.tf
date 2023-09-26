output "pub_key" {
  value       = acme_certificate.certificate.certificate_pem
  description = "Public key file from the acme_generation"
}

output "pub_key_chain" {
  value       = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
  description = "Public key certificate"
}

output "pub_key_chain_base64" {
  value       = base64encode("${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}")
  description = "Public key certificate chain in base64 format"
}

output "private_key" {
  value       = nonsensitive(acme_certificate.certificate.private_key_pem)
  description = "Private key contents"
}

output "private_key_base64" {
  value       = nonsensitive(base64encode(acme_certificate.certificate.private_key_pem))
  description = "Private key encoded in base64 format."
}


output "certificate_url" {
  value       = acme_certificate.certificate.certificate_url
  description = "Certificate URL"
}

output "certificate_issuer_pem" {
  value       = acme_certificate.certificate.issuer_pem
  description = "Certificate issuer"
}

output "private_key_location" {
  value       = local_file.private_key.filename
  description = "Path where the private key was exported on disk"
}

output "public_key_location" {
  value       = local_file.pub_key_chain.filename
  description = "Path where the private key was exported on disk"
}
output "elastic_ip" {
  value = aws_eip.stage_eip.public_ip
}
output "ssh_keypair" {
value = tls_private_key.key.private_key_pem
sensitive = true
}
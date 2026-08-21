output "build_host_ip" {
  value = aws_instance.build_host.public_ip
}

output "build_host_private_key" {
  value     = tls_private_key.build_host_key.private_key_pem
  sensitive = true
}

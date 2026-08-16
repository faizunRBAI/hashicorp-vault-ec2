output "instance_ip" {
  description = "Public Elastic IP address of the Vault instance"
  value       = aws_eip.vault.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.vault.id
}

output "vault_ui_url" {
  description = "Vault UI URL (HTTP — add HTTPS after TLS setup)"
  value       = "http://${aws_eip.vault.public_ip}/ui/"
}

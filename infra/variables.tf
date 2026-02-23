variable "ssh_key" {
  description = "Chave privada SSH para acessar a EC2"
  type        = string
  sensitive   = true
}
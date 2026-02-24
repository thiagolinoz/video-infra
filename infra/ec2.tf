resource "aws_instance" "app_server" {
  ami           = "ami-0f3caa1cf4417e51b"
  instance_type = "t3.medium"
  key_name      = "vockey" # Nome padrão da chave no AWS Academy
  subnet_id     = aws_subnet.subnet_public[0].id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]


  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable --now docker
              usermod -aG docker ec2-user
              # Instalar Docker Compose V2
              mkdir -p /usr/local/lib/docker/cli-plugins/
              curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              EOF

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.ssh_key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/../docker-compose.yaml"
    destination = "/home/ec2-user/docker-compose.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "timeout 300 bash -c 'while ! docker info > /dev/null 2>&1; do sleep 10; done'",
      "cd /home/ec2-user",
      # Captura o IP privado da instância atual
      "export PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)",
      # Sobe o docker passando essa variável
      "PRIVATE_IP=$PRIVATE_IP sudo -E docker compose up -d"
    ]
  }
}
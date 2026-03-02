resource "aws_instance" "app_server" {
  ami           = "ami-0f3caa1cf4417e51b"
  instance_type = "t3.medium"
  key_name      = "vockey" # Nome padrão da chave no AWS Academy
  subnet_id     = aws_subnet.subnet_public[0].id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name    = "Kafka-Server-video"
    Version = "2.1"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y docker
              sudo systemctl enable --now docker
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              cat <<EOT > /home/ec2-user/docker-compose.yml
              ${file("docker-compose.yml")}
              EOT

              cd /home/ec2-user/
              sudo /usr/local/bin/docker-compose up -d
              EOF
}

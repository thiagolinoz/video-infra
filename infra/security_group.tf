resource "aws_security_group" "sg_ec2" {
  name        = "sg_docker_final"
  description = "Libera SSH para o Terraform e portas para o EKS"
  vpc_id      = aws_vpc.fiap_video_vpc.id

  ingress {
    description = "SSH do GitHub Actions"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Acesso do EKS e Rede Interna"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "app_server" {
  ami           = "ami-0f3caa1cf4417e51b"
  instance_type = "t3.medium"
  key_name      = "vockey" # Nome padrão da chave no AWS Academy
  subnet_id     = aws_subnet.subnet_public[0].id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name    = "Kafka-Server-POC"
    Version = "2.1"
  }


  user_data = <<-EOF
              #!/bin/bash
              # 1. Instalar Docker e Docker Compose (Amazon Linux 2023)
              sudo dnf update -y
              sudo dnf install -y docker
              sudo systemctl enable --now docker
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              # 2. Obter o IP Privado da instância (IMDSv2)
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

              # 3. Criar o docker-compose.yml dinamicamente
              cat <<EOT > /home/ec2-user/docker-compose.yml
              version: '3'
              services:
                zookeeper:
                  image: confluentinc/cp-zookeeper:7.4.0
                  environment:
                    ZOOKEEPER_CLIENT_PORT: 2181

                kafka:
                  image: confluentinc/cp-kafka:7.4.0
                  depends_on:
                    - zookeeper
                  ports:
                    - "9092:9092"
                  environment:
                    KAFKA_BROKER_ID: 1
                    KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
                    KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://$PRIVATE_IP:9092
                    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
                    KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
                    KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

                kafka-ui:
                  image: provectuslabs/kafka-ui:latest
                  ports:
                    - "8088:8080"
                  depends_on:
                    - kafka
                  environment:
                    KAFKA_CLUSTERS_0_NAME: local
                    KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:29092
                    KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
              EOT

              # 4. Subir o Kafka
              cd /home/ec2-user/
              sudo /usr/local/bin/docker-compose up -d
              EOF

  user_data_replace_on_change = true
}

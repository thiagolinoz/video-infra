resource "aws_route53_zone" "private" {
  name = "video.internal"
  vpc {
    vpc_id = aws_vpc.fiap_video_vpc.id
  }
}

resource "aws_route53_record" "kafka" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "kafka.video.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.app_server.private_ip]
}
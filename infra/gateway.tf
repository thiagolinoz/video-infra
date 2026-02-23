resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fiap_video_vpc.id
  tags   = var.tags
}

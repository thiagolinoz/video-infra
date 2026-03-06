variable "region_default" {
  default = "us-east-1"
}

variable "project_name" {
  default = "postech-fiap-video"
}

variable "bucket_videos_name" {
  default = "postech-fiap-bucket-videos-fase5-dns"
}

variable "cidr_block_vpc" {
  default = "10.0.0.0/16"
}

variable "tags" {
  default = {
    Name = "postech-fiap-video"
  }
}

variable "role_lab" {
  default = "arn:aws:iam::072216138316:role/LabRole" #TODO trocar pelo AWSAccountId da conta que for executar
}

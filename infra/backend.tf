terraform {
  backend "s3" {
    bucket = "postech-fiap-video-backend-eks-dockerizado-2"
    key    = "backend/tfstate/terraform.tfstate"
    region = "us-east-1"
  }
}

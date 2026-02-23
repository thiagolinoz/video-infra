variable "repositorios" {
  type    = set(string)
  default = ["video-app", "video-frame-extractor", "video-processing-tracker"]
}

resource "aws_ecr_repository" "postech_fiap_video_repo" {
  for_each             = var.repositorios
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
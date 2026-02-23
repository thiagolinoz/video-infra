resource "aws_s3_bucket" "bucket-videos" {
   bucket = var.bucket_videos_name
   tags   = var.tags
}
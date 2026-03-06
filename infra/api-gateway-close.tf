resource "aws_api_gateway_rest_api" "app_video" {
  name        = "app_video"
  description = "API para aplicação de videos"
}

# /api
resource "aws_api_gateway_resource" "app_video_api" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_rest_api.app_video.root_resource_id
  path_part   = "api"
}

# /api/v1
resource "aws_api_gateway_resource" "app_video_v1" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_api.id
  path_part   = "v1"
}
# Cria a API
resource "aws_api_gateway_rest_api" "app_video_login" {
  name        = "app_video_login"
  description = "API para criação de usuário"
}

# /api
resource "aws_api_gateway_resource" "app_video_login_api" {
  rest_api_id = aws_api_gateway_rest_api.app_video_login.id
  parent_id   = aws_api_gateway_rest_api.app_video_login.root_resource_id
  path_part   = "api"
}

# /api/v1
resource "aws_api_gateway_resource" "app_video_login_v1" {
  rest_api_id = aws_api_gateway_rest_api.app_video_login.id
  parent_id   = aws_api_gateway_resource.app_video_login_api.id
  path_part   = "v1"
}

# /api/v1/user
resource "aws_api_gateway_resource" "app_video_login_user" {
  rest_api_id = aws_api_gateway_rest_api.app_video_login.id
  parent_id   = aws_api_gateway_resource.app_video_login_v1.id
  path_part   = "user"
}

# /api/v1/user/new
resource "aws_api_gateway_resource" "app_video_login_new" {
  rest_api_id = aws_api_gateway_rest_api.app_video_login.id
  parent_id   = aws_api_gateway_resource.app_video_login_user.id
  path_part   = "new"
}
######################################
###### POST /api/v1/user/new #########
######################################
resource "aws_api_gateway_method" "app_video_login_new_post" {
  rest_api_id   = aws_api_gateway_rest_api.app_video_login.id
  resource_id   = aws_api_gateway_resource.app_video_login_new.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "app_video_new_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app_video_login.id
  resource_id             = aws_api_gateway_resource.app_video_login_new.id
  http_method             = aws_api_gateway_method.app_video_login_new_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_video_app}/api/v1/user/new"

#   request_parameters = {
#     "integration.request.header.Authorization" = "method.request.header.Authorization"
#   }
}

# Deploy
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.app_video_new_user_integration]

  rest_api_id = aws_api_gateway_rest_api.app_video_login.id
#   stage_name  = "dev"
}

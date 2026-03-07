resource "aws_api_gateway_rest_api" "app_video" {
  name        = "app_video"
  description = "API para aplicação de videos"
}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                    = "lambda-authorizer"
  rest_api_id             = aws_api_gateway_rest_api.app_video.id
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer.arn}/invocations" #aws_lambda_function.authorizer.invoke_arn
  #authorizer_credentials = var.role_lab
  #identity_source        = "method.request.header.Authorization"
  type                   = "REQUEST"
  #   provider_arns           = [aws_cognito_user_pool.main.arn]
  authorizer_result_ttl_in_seconds = 0 # <--- sem cache
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

# /api/v1/user
resource "aws_api_gateway_resource" "app_video_user" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_v1.id
  path_part   = "user"
}

# /api/v1/user/{email}
resource "aws_api_gateway_resource" "app_video_email" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_user.id
  path_part   = "{email}"
}

###############################################
# /api/v1/user/{email}/videos
###############################################
resource "aws_api_gateway_resource" "app_video_email_videos" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_email.id
  path_part   = "videos"
}

# GET /api/v1/user/{email}/videos
resource "aws_api_gateway_method" "app_video_email_videos_GET" {
  rest_api_id   = aws_api_gateway_rest_api.app_video.id
  resource_id   = aws_api_gateway_resource.app_video_email_videos.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.email"          = true
  }
}

resource "aws_api_gateway_integration" "app_video_email_videos_GET_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app_video.id
  resource_id             = aws_api_gateway_resource.app_video_email_videos.id
  http_method             = aws_api_gateway_method.app_video_email_videos_GET.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_video_app}/api/v1/user/{email}/videos"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.path.email"          = "method.request.path.email"
  }
}

########################################################
# /api/v1/user/{email}/videos/{videoId}/download #######
########################################################
resource "aws_api_gateway_resource" "app_video_videoId" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_email_videos.id
  path_part   = "{videoId}"
}

resource "aws_api_gateway_resource" "app_video_videoId_download" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_videoId.id
  path_part   = "download"
}

# GET /api/v1/user/{email}/videos/{videoId}/download
resource "aws_api_gateway_method" "app_video_videoId_download_GET" {
  rest_api_id   = aws_api_gateway_rest_api.app_video.id
  resource_id   = aws_api_gateway_resource.app_video_videoId_download.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.email"          = true
    "method.request.path.videoId"          = true
  }
}

resource "aws_api_gateway_integration" "app_video_videoId_download_GET_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app_video.id
  resource_id             = aws_api_gateway_resource.app_video_videoId_download.id
  http_method             = aws_api_gateway_method.app_video_videoId_download_GET.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_video_app}/api/v1/user/{email}/videos/{videoId}/download"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.path.email"          = "method.request.path.email"
    "integration.request.path.videoId"          = "method.request.path.videoId"
  }
}

############################################
# /api/v1/user/{email}/videos/upload-url ###
############################################
resource "aws_api_gateway_resource" "app_video_upload_url" {
  rest_api_id = aws_api_gateway_rest_api.app_video.id
  parent_id   = aws_api_gateway_resource.app_video_email_videos.id
  path_part   = "upload-url"
}

# POST /api/v1/user/{email}/videos/upload
resource "aws_api_gateway_method" "app_video_upload_url_POST" {
  rest_api_id   = aws_api_gateway_rest_api.app_video.id
  resource_id   = aws_api_gateway_resource.app_video_upload_url.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.email"          = true
  }
}

resource "aws_api_gateway_integration" "app_video_upload_url_POST_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app_video.id
  resource_id             = aws_api_gateway_resource.app_video_upload_url.id
  http_method             = aws_api_gateway_method.app_video_upload_url_POST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.url_s3_post.arn}/invocations"

}

############################################
########## DEPLOYMENT SESSION ##############
############################################

resource "aws_api_gateway_deployment" "app_video_deployment" {
  depends_on = [
     aws_api_gateway_integration.app_video_email_videos_GET_integration,
     aws_api_gateway_integration.app_video_videoId_download_GET_integration,
    aws_api_gateway_integration.app_video_upload_url_POST_integration,
     aws_api_gateway_authorizer.lambda_authorizer
  ]

  rest_api_id = aws_api_gateway_rest_api.app_video.id
  description = "Deployment for video_app"

  # Força nova deployment quando há mudanças
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.app_video_email_videos.id,
      aws_api_gateway_method.app_video_email_videos_GET.id,
      aws_api_gateway_integration.app_video_email_videos_GET_integration.id,
      aws_api_gateway_resource.app_video_videoId.id,
      aws_api_gateway_method.app_video_videoId_download_GET.id,
      aws_api_gateway_integration.app_video_videoId_download_GET_integration.id,
      aws_api_gateway_method.app_video_upload_url_POST.id,
      aws_api_gateway_resource.app_video_upload_url.id,
      aws_api_gateway_integration.app_video_upload_url_POST_integration.id,
#      aws_api_gateway_method.pessoa_post.id,
#       aws_api_gateway_authorizer.lambda_authorizer.id,

    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Cria o stage 'prod'
resource "aws_api_gateway_stage" "video_app_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.app_video.id
  deployment_id = aws_api_gateway_deployment.app_video_deployment.id

  variables = {
    # aqui você pode definir variáveis de stage se quiser
  }
}
resource "aws_lambda_function" "authorizer" {
  filename      = data.archive_file.authorizer.output_path
  function_name = "${var.project_name}-authorizer-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.authorizer.output_base64sha256
}

resource "aws_lambda_function" "url_s3_post" {
  filename      = data.archive_file.s3_url_post.output_path
  function_name = "${var.project_name}-url-s3-post-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.s3_url_post.output_base64sha256
}
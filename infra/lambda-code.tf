data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "postech-fiap-video-app-authorizer.zip"

  source {
    content  = <<EOF
import boto3
import base64


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Persons')

def lambda_handler(event, context):

    method_arn = event["methodArn"]

    headers = {k.lower(): v for k, v in event["headers"].items()}
    auth_header = headers.get("authorization")
    print ("Authorization header:", auth_header)
    if auth_header and auth_header.startswith("Basic "):
        try:
            encoded_credentials = auth_header.split(" ")[1]

            decoded = base64.b64decode(encoded_credentials).decode("utf-8")

            email, senha = decoded.split(":")
        except:
            print('{"statusCode": 400, "body": "Credenciais inválidas"}')
            effect = "Deny"
            return {
                "principalId": "test-user",
                "policyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": "execute-api:Invoke",
                            "Effect": effect,
                            "Resource": method_arn
                        }
                    ]
                }
            }

    if email or senha:
        response = table.get_item(Key={"nmEmail": email})

        if "Item" in response:
            senha_banco = response["Item"]["cdPassword"]
            if senha_banco == senha:
                print('{"statusCode": 200, "body": "Login autorizado"}')
                effect = "Allow"
            else:
                print('{"statusCode": 401, "body": "Senha inválida"}')
                effect = "Deny"
        else:
            print('{"statusCode": 404, "body": "Usuário não encontrado"}')
            effect = "Deny"

    else:
        print ('{"statusCode": 400, "body": "Email e senha obrigatórios"}')
        effect = "Deny"

    return {
        "principalId": "test-user",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": method_arn
                }
            ]
        }
    }
EOF
    filename = "index.py"
  }
}

data "archive_file" "s3_url_post" {
  type        = "zip"
  output_path = "postech-fiap-video-app-s3-url-post.zip"

  source {
    content  = <<EOF
import boto3
import json

s3 = boto3.client("s3")

BUCKET = "postech-fiap-bucket-videos-fase5"

def lambda_handler(event, context):
    body = event.get("body")
    if body:
        body = json.loads(body)
    else:
        body = {}

    file_name = body.get("fileName", "default.mp4")


    email = event["pathParameters"]["email"]
    key = f"videos/{email}/{file_name}"

    response = s3.generate_presigned_post(
        Bucket=BUCKET,
        Key=key,
        ExpiresIn=300
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(response)
    }
EOF
    filename = "index.py"
  }
}
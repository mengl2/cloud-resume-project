data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb_policy"
  path        = "/"
  description = "dynamodb policy to have permissions to read and write to dynamodb table"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1736092283798",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:UpdateItem",
        "dynamodb:UpdateTable",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:*:*:table/cloudresume-test"
    }
  ]
  })
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  
}

data "archive_file" "zip_python" {
  type        = "zip"
  source_file = "${path.module}/lambda/visitorcount.py"
  output_path = "${path.module}/lambda/visitorcount.zip"
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_lambda_function" "viewscounter" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.zip_python.output_path
  function_name = "viewscounter"
  role          = aws_iam_role.iam_for_lambda.arn
 
  handler       = "visitorcount.lambda_handler"

  source_code_hash = data.archive_file.zip_python.output_base64sha256

  runtime = "python3.13"

}



resource "aws_lambda_function_url" "test_live" {
  function_name      = aws_lambda_function.viewscounter.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
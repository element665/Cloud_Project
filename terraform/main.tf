
resource "aws_lambda_function" "visitor_counter" {
  function_name = "resume-visitor-counter"
  handler       = "main.lambda_handler"
  runtime       = "python3.14"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "main.py.zip"

  environment {
    variables = {
      TABLE_NAME = "resume-visitor-count"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "resume-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

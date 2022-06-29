# Zip the lambda code
data "archive_file" "init" {
  type        = "zip"
  source_dir  = "lambda_code/"
  output_path = "output_lambda_zip/startstop_ec2.zip"
}

# Create lambda function
resource "aws_lambda_function" "startstop_ec2_function" {
  filename      = data.archive_file.init.output_path
  function_name = "StartStopEC2"
  role          = aws_iam_role.role.arn
  handler       = "main_handler.lambda_handler"
  description   = "Start/Stop EC2 on a schedule"
  tags          = { Name = "${var.name-prefix}-lambda" }

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.init.output_path)

  runtime = "python3.9"
  timeout = "120"
}
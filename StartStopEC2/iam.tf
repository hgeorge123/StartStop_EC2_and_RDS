data "aws_iam_policy_document" "policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "StartStopEC2"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:Start*",
      "ec2:Stop*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "role_source" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "policy" {
  name        = "StartStopEC2_policy"
  path        = "/"
  description = "StartStopEC2 Policy"
  policy      = data.aws_iam_policy_document.policy_source.json
  tags        = { Name = "${var.name-prefix}-policy" }
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "role" {
  name               = "StartStopEC2_policy_role"
  assume_role_policy = data.aws_iam_policy_document.role_source.json
  tags               = { Name = "${var.name-prefix}-role" }
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
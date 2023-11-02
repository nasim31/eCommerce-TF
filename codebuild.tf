#Code Build

resource "aws_codebuild_project" "eCommerce-codebuild" {
  name = "eCommerce-codebuild"
  build_timeout = "30"
  service_role = "${aws_iam_role.eCommerce-codebuild-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_iam_role" "eCommerce-codebuild-role" {
  name = "eCommerce-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_api_engine_policy" {
    name = "eCommerce-codebuild-role_policy"
    role = aws_iam_role.eCommerce-codebuild-role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "s3:*",
        "cloudwatch:*"
      ]
    }
  ]
}
POLICY
}
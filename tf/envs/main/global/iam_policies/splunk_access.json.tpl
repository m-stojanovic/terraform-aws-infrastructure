{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SplunkPolicy",
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "logs:*",
                "sqs:*",
                "cloudwatch:*",
                "kinesis:Get*",
                "kinesis:List*",
                "kinesis:DescribeStream*",
                "inspector:*",
                "config:*",
                "s3:Get*",
                "s3:List*",
                "sns:Get*",
                "sns:List*",
                "sns:Publish",
                "lambda:List*",
                "rds:DescribeDBInstances",
                "elasticloadbalancing:Describe*",
                "cloudfront:ListDistributions",
                "iam:ListAccessKeys",
                "iam:GetAccessKeyLastUsed",
                "iam:GetAccountPasswordPolicy",
                "iam:ListUsers",
                "iam:GetUser"
            ],
            "Resource": "*"
        }
    ]
}
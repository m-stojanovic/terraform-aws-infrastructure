{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-1:123456789876:parameter/*",
        "arn:aws:secretsmanager:eu-west-1:123456789876:secret:*",
        "arn:aws:kms:eu-west-1:123456789876:alias/${environment}-ssm-key"
      ]
    }
  ]
}

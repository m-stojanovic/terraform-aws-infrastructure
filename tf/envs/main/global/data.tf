# TEMPLATES FOR IAM POLICIES
data "template_file" "ecs_task_assume_role_policy" {
  template = file("${path.module}/iam_policies/assume-role-policy.json.tpl")
  vars = {
    service = "ecs-tasks.amazonaws.com"
  }
}

data "template_file" "ssm_kms_secrets_access_policy_prod" {
  template = file("${path.module}/iam_policies/ssm-secrets-kms.json.tpl")
  vars = {
    environment = "prod"
  }
}

data "template_file" "billing_s3_read_only_policy" {
  template = file("${path.module}/iam_policies/s3_readonly_policy.json.tpl")
  vars = {
    blue_green_bucket = "devops-detailed-billing"
  }
}

data "template_file" "splunk_access" {
  template = file("${path.module}/iam_policies/splunk_access.json.tpl")
}


# EXECUTION ROLE
resource "aws_iam_role" "ecsTask_execution_role_production" {
  path               = "/"
  name               = "ECSDevopsProdecsTasksExecutionRole"
  description        = "Role used for ecs task execution in production"
  assume_role_policy = data.template_file.ecs_task_assume_role_policy.rendered
}

# IAM ROLE POLICIES
resource "aws_iam_role_policy" "ssm_kms_secrets_policy_production" {
  name   = "ECSDevopsProductionSSMSecretsKMSAccessPolicy"
  role   = aws_iam_role.ecsTask_execution_role_production.name
  policy = data.template_file.ssm_kms_secrets_access_policy_prod.rendered
}

resource "aws_iam_role_policy" "s3_readonly_policy" {
  name   = "DevopsS3ReadOnlyAccessPolicy"
  role   = "ECSGreenecsTasksExecutionRole"
  policy = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::devops-blue-green-prod-deployments/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::devops-blue-green-prod-deployments"
      ]
    }
  ]
}
EOT
}

# IAM POLICIES
resource "aws_iam_policy" "s3_read_only_billing_policy" {
  name        = "S3DetailedBillingReadOnlyPolicy"
  description = "Policy for read only access to the detailed billing s3 bucket"
  policy      = data.template_file.billing_s3_read_only_policy.rendered
}

resource "aws_iam_policy" "splunk_access_policy" {
  name        = "SplunkCloudAcccessPolicy"
  description = "Policy for read only access to the SplunkCloud resources"
  policy      = data.template_file.splunk_access.rendered
}
# IAM POLICY ATTACHMENTS
resource "aws_iam_role_policy_attachment" "ecs_dynamodb_full_access_policy_attachment" {
  role       = "ECSDevopsProdecsTasksExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ecs_task_execution_policy_attachment" {
  role       = "ECSDevopsProdecsTasksExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy_attachment" "splunkcloud_policy_attachment" {
  name       = "SplunkCloudAcccessPolicyAttachment"
  users      = [module.iam_user["splunkcloud"].user_name]
  policy_arn = aws_iam_policy.splunk_access_policy.arn
}
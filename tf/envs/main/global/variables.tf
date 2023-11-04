variable "ecr_repository" {
  description = "List of repositories to create"
  type        = list(any)
  default = [
    "devops/fluent-bit"
  ]
}

variable "iam_user" {
  description = "List of IAM Users to create"
  default = {
    "devops.user" = {
      group           = ["DevOps"]
      access_key      = true
      create_password = true
      public_key      = ""
      title           = "DevOps Engineer"
      access_level    = "Administrator"
      email           = "devops.user@devops.com"
      name            = "Devops User"
      pgp_key         = null
    }
  }
}

variable "iam-group" {
  default = {
    "Billing" = {
      group_policies = [
        "arn:aws:iam::aws:policy/AWSSavingsPlansFullAccess",
        "arn:aws:iam::aws:policy/job-function/Billing",
        "arn:aws:iam::aws:policy/IAMUserChangePassword"
      ]
      computed_number_of_policies = 3
    }
    "StabilityProject" = {
      group_policies = [
        "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
        "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
        "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
        "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
        "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
        "arn:aws:iam::123456789876:policy/IAMCreatePolicy",
        "arn:aws:iam::123456789876:policy/ecr-authenticate",
        "arn:aws:iam::123456789876:policy/DevdevopsRoute53",
        "arn:aws:iam::aws:policy/IAMUserChangePassword"
      ]
      computed_number_of_policies = 10
    }
    "Developers" = {
      group_policies = [
        "arn:aws:iam::123456789876:policy/AmazonManageVirtualMFADevice",
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/IAMUserChangePassword",
        "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
        "arn:aws:iam::123456789876:policy/S3_Devops_Static_Upload"
      ]
      computed_number_of_policies = 5
    }
    "s3-access" = {
      group_policies = [
        "arn:aws:iam::123456789876:policy/AmazonManageVirtualMFADevice",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/IAMUserChangePassword",
        "arn:aws:iam::123456789876:policy/IAMSelfManagePassword",
        "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
      ]
      computed_number_of_policies = 5
    }
  }
}

variable "iam_role" {
  default = {
    "ecsCodeDeployRole" = {
      description              = "Role for code deploy applications to ECS"
      create_iam_role_policy   = true
      create_policy_attachment = true
      path                     = "/"
      assume_role_policy       = <<-EOT
        {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
        }
        EOT
      policy_arn               = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECSLimited"
      iam_role_policy_name     = "PassRoleToECSTaskExecutionRolePolicy"
      iam_role_policy          = <<-EOF
      {
          "Version": "2012-10-17",
          "Statement": [
          {
              "Action": "iam:PassRole",
              "Effect": "Allow",
              "Resource": [
              "arn:aws:iam::123456789876:role/ECSGreenecsTasksExecutionRole"
              ]
          }
          ]
      }
      EOF
    }
  }
}

variable "kms_key" {
  default = {
    "Key to encode and decode SSM parameters for prod" = {
      alias  = "alias/prod-ssm-key"
      policy = <<-EOT
  {
      "Version": "2012-10-17",
      "Id": "key-consolepolicy-3",
      "Statement": [
          {
              "Sid": "Enable IAM User Permissions",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:root"
              },
              "Action": "kms:*",
              "Resource": "*"
          },
          {
              "Sid": "Allow access for Key Administrators",
              "Effect": "Allow",
              "Principal": {
                  "AWS": [
                      "arn:aws:iam::123456789876:user/terraform"
                  ]
              },
              "Action": [
                  "kms:Create*",
                  "kms:Describe*",
                  "kms:Enable*",
                  "kms:List*",
                  "kms:Put*",
                  "kms:Update*",
                  "kms:Revoke*",
                  "kms:Disable*",
                  "kms:Get*",
                  "kms:Delete*",
                  "kms:TagResource",
                  "kms:UntagResource",
                  "kms:ScheduleKeyDeletion",
                  "kms:CancelKeyDeletion"
              ],
              "Resource": "*"
          },
          {
              "Sid": "Allow use of the key",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:role/ECSDevopsProdecsTasksExecutionRole"
              },
              "Action": [
                  "kms:Encrypt",
                  "kms:Decrypt",
                  "kms:ReEncrypt*",
                  "kms:GenerateDataKey*",
                  "kms:DescribeKey"
              ],
              "Resource": "*"
          },
          {
              "Sid": "Allow SSM actions",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:user/terraform"
              },
              "Action": [
                  "ssm:PutParameter",
                  "ssm:GetParameter*"
              ],
              "Resource": "arn:aws:ssm:eu-west-1:123456789876:parameter/prod*"
          },
          {
              "Sid": "Allow attachment of persistent resources",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:role/ECSDevopsProdecsTasksExecutionRole"
              },
              "Action": [
                  "kms:CreateGrant",
                  "kms:ListGrants",
                  "kms:RevokeGrant"
              ],
              "Resource": "*",
              "Condition": {
                  "Bool": {
                      "kms:GrantIsForAWSResource": "true"
                  }
              }
          }
      ]
  }
  EOT
    }
  }
}

variable "buckets" {
  default = {
    "devops-vcc-payment" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = true
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = false
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = null
      target_bucket           = "logs-devops-main"
      target_prefix           = "devops-vcc-payment/"
      sse_algorithm           = "aws:kms"
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = null
    }
    "logs-devops-main" = {
      create_acl              = true
      create_logging          = false
      create_encryption       = true
      create_versioning       = false
      create_lifecycle        = true
      create_cors             = false
      create_policy           = false
      create_notification     = false
      grant                   = ""
      acl                     = "log-delivery-write"
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = ""
      target_prefix           = ""
      sse_algorithm           = "AES256"
      lifecycle_rules = {
        rule = {
          id     = "Lifecycle rule for prefix prod-gr"
          status = "Enabled"

          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 60
              storage_class = "GLACIER"
            }
          ]
          filter = {
            prefix = "prod-gr"
          }
        }
      }
      expected_bucket_owner = null
      cors_rule             = null
      sqs_notification      = null
      bucket_policy         = null
    }
    "cordial-bl.devops.co.uk" = {
      create_acl              = true
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = true
      create_policy           = true
      create_notification     = false
      grant                   = []
      acl                     = "private"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = false
      restrict_public_buckets = true
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule = {
        rule = {
          allowed_methods = [
            "GET",
            "POST",
          ]
          allowed_origins = [
            "https://*.devops.co.uk",
          ]
          allowed_headers = [
            "*",
          ]
          expose_headers  = []
          max_age_seconds = 86400
        }
      }
      sqs_notification = null
      bucket_policy    = <<-EOT
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::cordial-bl.devops.co.uk/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "10.249.44.0/22"
                    ]
                }
            }
        }
    ]
}
EOT
    }
    "citrusad.devops.co.uk" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = []
      acl                     = "private"
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = "Enabled"
      target_bucket           = "logs.devops.co.uk"
      target_prefix           = "citrusad.devops.co.uk/"
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CitrusADCloudfalre",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::citrusad.devops.co.uk/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "198.41.128.0/17"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::citrusad.devops.co.uk",
                "arn:aws:s3:::citrusad.devops.co.uk/*"
            ]
        }
    ]
}
EOT
    }
    "citrusadtest.devdevops.co.uk" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = true
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = "logs-devops-main"
      target_prefix           = "citrusadtest.devdevops.co.uk/"
      sse_algorithm           = "aws:kms"
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::citrusadtest.devdevops.co.uk",
                "arn:aws:s3:::citrusadtest.devdevops.co.uk/*"
            ]
        }
    ]
}
EOT
    }
    "devops-blue-green-prod-deployments" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = true
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = false
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = null
      target_bucket           = "logs.devops.co.uk"
      target_prefix           = "devops-blue-green-prod-deployments/"
      sse_algorithm           = "aws:kms"
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = null
    }
    "fr-devops" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
  "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AddPermissionS3Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectTagging",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:GetObjectTagging"
            ],
            "Resource": [
                "arn:aws:s3:::fr-devops/*",
                "arn:aws:s3:::fr-devops"
            ]
        }
    ]
}
EOT
    }
    "cordial.devops.co.uk" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = true
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = false
      block_public_policy     = true
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = "logs.devops.co.uk"
      target_prefix           = "cordial.devops.co.uk/"
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule = {
        rule = {
          allowed_methods = [
            "GET",
            "POST",
          ]
          allowed_origins = [
            "https://*.devops.co.uk",
          ]
          allowed_headers = [
            "*",
          ]
          expose_headers  = []
          max_age_seconds = 86400
        }
      }
      sqs_notification = null
      bucket_policy    = <<-EOT
{
  "Version": "2008-10-17",
  "Statement": [


    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::cordial.devops.co.uk/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "10.249.44.0/22"
          ]
        }
      }
    }
  ]
}
EOT
    }
    "ls-redirects" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::ls-redirects/*"
        }
    ]
}
EOT
    }
    "cloudfront-logs-devops-livingsocial" = {
      create_acl          = true
      create_logging      = true
      create_encryption   = false
      create_versioning   = true
      create_lifecycle    = false
      create_cors         = false
      create_policy       = false
      create_notification = true
      grant = {
        grant_1 = {
          type       = "Group"
          permission = "WRITE"
          uri        = "http://acs.amazonaws.com/groups/s3/LogDelivery"
        },
        grant_2 = {
          type       = "CanonicalUser"
          permission = "FULL_CONTROL"
          id         = "4c61882c7206fa863a7fe28a138d82b0f412b2d71037c20a5c34aa6a1872dbc5"
        }
      }
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = "Enabled"
      target_bucket           = "cloudfront-logs-devops-livingsocial"
      target_prefix           = ""
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification = {
        queue = {
          id        = "NewLogCreated"
          queue_arn = "arn:aws:sqs:eu-west-1:123456789876:ProductionLogs"
          events    = ["s3:ObjectCreated:*"]
        }
      }
      bucket_policy = null
    }
    "logs.devops.co.uk" = {
      create_acl          = true
      create_logging      = true
      create_encryption   = false
      create_versioning   = false
      create_lifecycle    = true
      create_cors         = false
      create_policy       = true
      create_notification = true
      grant = {
        grant_1 = {
          type       = "Group"
          permission = "FULL_CONTROL"
          uri        = "http://acs.amazonaws.com/groups/s3/LogDelivery"
        },
        grant_2 = {
          type       = "CanonicalUser"
          permission = "FULL_CONTROL"
          id         = "4c61882c7206fa863a7fe28a138d82b0f412b2d71037c20a5c34aa6a1872dbc5"
        },
        grant_3 = {
          type       = "CanonicalUser"
          permission = "FULL_CONTROL"
          id         = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
        }
      }
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = "logs-devops-main"
      target_prefix           = ""
      sse_algorithm           = null
      lifecycle_rules = {
        rule_1 = {
          id     = "dev|int Log Rotataion - 5 Days"
          status = "Enabled"
          expiration = {
            days = 5
          }
          filter = {
            prefix = "dev-cloudfront/, dev-elb/, int-cloudfront/, int-elb/"
          }
        },
        rule_2 = {
          id     = "Cloudtrail, logs and prod logs archive to Glacier"
          status = "Enabled"
          transition = {
            days          = 30
            storage_class = "GLACIER"
          }
          expiration = {
            days = 365
          }
          filter = {
            prefix = "cloudtrail/, logs/, prod-cloudfront/, prod-elb/, prod-website/"
          }
        },
        rule_3 = {
          id     = "Lifecycle rule for prefix prod-gr"
          status = "Enabled"
          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 60
              storage_class = "GLACIER"
            }
          ]
          filter = {
            prefix = "prod-gr"
          }
        }
      }
      expected_bucket_owner = null
      cors_rule             = null
      sqs_notification = {
        queue = {
          id        = "NewLogEvent"
          queue_arn = "arn:aws:sqs:eu-west-1:123456789876:ProductionLogs"
          events    = ["s3:ObjectCreated:*"]
        }
        queue = {
          id            = "tf-s3-queue-20230703184011823200000001"
          queue_arn     = "arn:aws:sqs:eu-west-1:123456789876:devops-splunk-cloudtrail"
          events        = ["s3:ObjectCreated:*"]
          filter_prefix = "cloudtrail/AWSLogs/123456789876/"
        }
      }
      bucket_policy = <<-EOT
{
    "Version": "2008-10-17",
    "Id": "Policy1400592378789",
    "Statement": [
        {
            "Sid": "Stmt1537368605133",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::logs.devops.co.uk/prod-gr/AWSLogs/123456789876/*"
        }
    ]
}
EOT
    } 
    "private-mkt-devops" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = true
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule = {
        rule = {
          allowed_methods = [
            "GET",
            "PUT",
            "POST"
          ]
          allowed_origins = [
            "*",
          ]
          allowed_headers = [
            "*",
          ]
          expose_headers  = []
          max_age_seconds = 3000
        }
      }
      sqs_notification = null
      bucket_policy    = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::private-mkt-devops/*"
        }
    ]
}
EOT
    }
    "aws-splunk-bucket" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = "Enabled"
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
      "Version": "2008-10-17",
      "Id": "Policy1335892530063",
      "Statement": [
          {
              "Sid": "Stmt1335892150622",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:root"
              },
              "Action": [
                  "s3:GetBucketAcl",
                  "s3:GetBucketPolicy"
              ],
              "Resource": "arn:aws:s3:::aws-splunk-bucket"
          },
          {
              "Sid": "Stmt1335892526596",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:root"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::aws-splunk-bucket/*"
          }
      ]
  }
EOT
    }
    "jobs.devops.co.uk" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = "Enabled"
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::jobs.devops.co.uk/*"
        }
    ]
}
EOT
    }
    "booking-calendar-admin.devdevops.co.uk" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = "Enabled"
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2012-10-17",
    "Id": "Policy1538128465937",
    "Statement": [
        {
            "Sid": "Stmt1538128457602",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::booking-calendar-admin.devdevops.co.uk/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "10.249.202.0/22"
                    ]
                }
            }
        }
    ]
}
EOT
    }
    "devops-splunk" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSConfigBucketPermissionsCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::devops-splunk"
        },
        {
            "Sid": "AWSConfigBucketDelivery",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::devops-splunk/AWSLogs/123456789876/Config/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
EOT
    }
    "devops-detailed-billing" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = true
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = "Enabled"
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = "AES256"
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2008-10-17",
    "Id": "Policy1335892530063",
    "Statement": [
        {
            "Sid": "Stmt1335892150622",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": [
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::devops-detailed-billing"
        },
        {
            "Sid": "Stmt1335892526596",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::devops-detailed-billing/*"
        }
    ]
}
EOT
    }
    "static.devops.co.uk" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = true
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules = {
        rule_1 = {
          id     = "expire static.devops deal-preview files after 1 day"
          status = "Enabled"
          expiration = {
            days = 1
          }
          filter = {
            prefix = "deal-preview/*"
          }
        }
      }
      expected_bucket_owner = null
      cors_rule             = null
      sqs_notification      = null
      bucket_policy         = <<-EOT
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::static.devops.co.uk/*"
        },
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789876:root"
            },
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::static.devops.co.uk/*",
                "arn:aws:s3:::static.devops.co.uk"
            ]
        }
    ]
}
EOT
    }
    "alb-ecs-log-bucket" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
      "Version": "2012-10-17",
      "Id": "LogBucketPolicy",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::123456789876:root"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::alb-ecs-log-bucket/*"
          }
      ]
}
EOT
    }
    "booking-calendar-admin.nxtdevops.co.uk" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = false
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = "Enabled"
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = <<-EOT
{
    "Version": "2012-10-17",
    "Id": "Policy1538128465937",
    "Statement": [
        {
            "Sid": "Stmt1538128457602",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::booking.devops.co.uk/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "198.1.1.0/17"
                    ]
                }
            }
        }
    ]
}
EOT
    }
    "private-mkt-nxtdevops" = {
      create_acl              = false
      create_logging          = false
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = false
      create_cors             = true
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = null
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = "Enabled"
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = null
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule = {
        rule = {
          allowed_methods = [
            "GET",
            "PUT",
            "POST"
          ]
          allowed_origins = [
            "*",
          ]
          allowed_headers = [
            "*",
          ]
          expose_headers  = []
          max_age_seconds = 3000
        }
      }
      sqs_notification = null
      bucket_policy    = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::private-mkt-nxtdevops/*"
        }
    ]
}
EOT
    }
    "video.devops.co.uk" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = false
      create_versioning       = true
      create_lifecycle        = true
      create_cors             = true
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = "Enabled"
      target_bucket           = "logs.devops.co.uk"
      target_prefix           = "video.devops.co.uk/"
      sse_algorithm           = null
      lifecycle_rules = {
        rule_1 = {
          id     = "expire video deal-preview files after 1 day"
          status = "Enabled"
          expiration = {
            days = 1
          }
          filter = {
            prefix = "deal-preview/*"
          }
        }
      }
      expected_bucket_owner = null
      cors_rule = {
        rule = {
          allowed_methods = [
            "GET",
            "POST"
          ]
          allowed_origins = [
            "https://*.devops.co.uk",
          ]
          allowed_headers = [
            "*",
          ]
          expose_headers  = []
          max_age_seconds = 86400
        }
      }
      sqs_notification = null
      bucket_policy    = <<-EOT
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "accesstobucket",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::video.devops.co.uk/*"
        },
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::video.devops.co.uk/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "10.249.44.0/22"
                    ]
                }
            }
        }
    ]
}
EOT
    }
    "video02.nxtdevops.co.uk" = {
      create_acl              = true
      create_logging          = true
      create_encryption       = false
      create_versioning       = false
      create_lifecycle        = true
      create_cors             = true
      create_policy           = true
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
      versioning              = null
      target_bucket           = "logs.devops.co.uk"
      target_prefix           = "video.devops.co.uk/"
      sse_algorithm           = null
      lifecycle_rules = {
        rule_1 = {
          id     = "expire video deal-preview files after 1 day"
          status = "Enabled"
          expiration = {
            days = 1
          }
          filter = {
            prefix = "deal-preview/*"
          }
        }
      }
      expected_bucket_owner = null
      cors_rule = {
        rule = {
          allowed_methods = [
            "GET",
            "POST"
          ]
          allowed_origins = [
            "https://*.nxtdevops.co.uk",
          ]
          allowed_headers = [
            "*",
          ]
          expose_headers  = []
          max_age_seconds = 86400
        }
      }
      sqs_notification = null
      bucket_policy    = <<-EOT
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::video02.nxtdevops.co.uk/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "10.249.44.0/22"
          ]
        }
      }
    }
  ]
}
EOT
    }
    "devops-ecr-vulnerability-reports" = {
      create_acl              = true
      create_logging          = false
      create_encryption       = true
      create_versioning       = false
      create_lifecycle        = false
      create_cors             = false
      create_policy           = false
      create_notification     = false
      grant                   = ""
      acl                     = "private"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = null
      target_bucket           = null
      target_prefix           = null
      sse_algorithm           = "aws:kms"
      lifecycle_rules         = null
      expected_bucket_owner   = null
      cors_rule               = null
      sqs_notification        = null
      bucket_policy           = null
    }
  }
}

variable "route53-records" {
  default = {
    "superset" = {
      records = {
        zone_name = "devops.tech"
        type      = "CNAME"
        ttl       = "5"
        record    = ["internal-bi-alb-111.eu-west-1.elb.amazonaws.com"]
      }
    }
    "airflow-worker" = {
      records = {
        zone_name = "devops.tech"
        type      = "CNAME"
        ttl       = "5"
        record    = ["internal-bi-alb-111.eu-west-1.elb.amazonaws.com"]
      }
    }
    "airflow-master" = {
      records = {
        zone_name = "devops.tech"
        type      = "CNAME"
        ttl       = "5"
        record    = ["internal-bi-alb-111.eu-west-1.elb.amazonaws.com"]
      }
    }
  }
}

variable "tags" {}
variable "aws_account_id" {}

module "ecr_repository" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-ecr-repository"
  for_each = toset(var.ecr_repository)

  repository_name          = each.value
  number_of_images_to_keep = "20"
  principal                = "arn:aws:iam::123456789876:user/jenkins_ecr_user"
  scan_on_push             = true
}

module "aws_cloudfront_distribution_booking_app" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-cloudfront/v1"

  cf_description       = "Calender booking app"
  s3_target            = "booking-calendar-admin.devops.co.uk.s3-website-eu-west-1.amazonaws.com"
  cf_priceclass        = "PriceClass_100"
  cf_alternate_domains = ["booking-calendar-admin.devops.co.uk"]
  cf_protocol_ploicy   = "redirect-to-https"
  acm_cert_arn         = "arn:aws:acm:us-east-1:123456789876:certificate/c6fd15d7-4d03-4f79-880e-034861d174a6"
}

module "iam_user" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-iam/iam-user"
  for_each = var.iam_user

  user_name          = each.key
  groups             = each.value.group
  create_access_keys = each.value.access_key
  create_password    = each.value.create_password
  upload_ssh_key     = false
  public_key         = each.value.public_key
  title              = each.value.title
  access_level       = each.value.access_level
  email              = each.value.email
  name               = each.value.name
  pgp_key            = each.value.pgp_key
}

# module "iam_ecs" {
#   source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-iam/iam-ecs"
#   for_each = var.iam_ecs

#   username             = each.key
#   environment_name_iam = each.value.environment_name_iam
# }

module "iam-group" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-iam/iam-group"
  for_each = var.iam-group

  group_name                  = each.key
  group_policies              = each.value.group_policies
  computed_number_of_policies = each.value.computed_number_of_policies
}

module "iam_role" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-iam/iam-role"
  for_each = var.iam_role

  name                     = each.key
  path                     = each.value.path
  description              = each.value.description
  assume_role_policy       = each.value.assume_role_policy
  policy_arn               = each.value.policy_arn
  iam_role_policy_name     = each.value.iam_role_policy_name
  iam_role_policy          = each.value.iam_role_policy
  create_policy_attachment = each.value.create_policy_attachment
  create_iam_role_policy   = each.value.create_iam_role_policy
  tags                     = var.tags
}

module "iam_default" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-iam/iam-default"

  policy_name                          = "prod01_policy"
  profile_name                         = "prod01_profile"
  role_name                            = "prod01_role"
  s3_bucket_limited_access_policy_name = "S3-prod01-Bucket-Limited-Access"
  policy_sid                           = "Listprod01devopsBucketOnly"
  static_url                           = "static01.proddevops.co.uk"
  videos_s3_bucket_url                 = "video01.proddevops.co.uk"
  mkt_bucket                           = "private-mkt-proddevops"
  av_bucket                            = "av-proddevops"
  private_bucket                       = "private01.proddevops.co.uk"
  redshift_data_bucket                 = "redshift-data-prod"
  environment                          = "prod"
  sns_publish_policy_name              = "SNS-prod01-Publish"
  environment_name                     = "prod01"
  sqs_send_receive_delete_policy_name  = "SQS-prod01-SendReceiveDelete"
  iam_group_name                       = "vpc-prod01app"
  group_membership_name                = "prod01-group-membership"
  iam_vpc_user                         = "vpcprod-grdevops"
}

module "kms" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-kms"
  for_each = var.kms_key

  description             = each.key
  alias                   = each.value.alias
  deletion_window_in_days = try(each.value.deletion_window_in_days, null)
  enable_key_rotation     = try(each.value.enable_key_rotation, null)
  policy                  = each.value.policy
}

module "s3-bucket" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-s3"
  for_each = var.buckets

  create_acl          = each.value.create_acl
  create_logging      = each.value.create_logging
  create_encryption   = each.value.create_encryption
  create_versioning   = each.value.create_versioning
  create_lifecycle    = each.value.create_lifecycle
  create_cors         = each.value.create_cors
  create_policy       = each.value.create_policy
  create_notification = each.value.create_notification

  bucket                  = each.key
  acl                     = each.value.acl
  grants                  = each.value.grant
  target_bucket           = each.value.target_bucket
  target_prefix           = each.value.target_prefix
  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
  sse_algorithm           = each.value.sse_algorithm
  versioning              = each.value.versioning
  lifecycle_rules         = each.value.lifecycle_rules
  cors_rules              = each.value.cors_rule
  expected_bucket_owner   = each.value.expected_bucket_owner
  bucket_policy           = each.value.bucket_policy
  sqs_notification        = each.value.sqs_notification
  tags                    = var.tags
}

module "route53-records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  for_each  = var.route53-records
  zone_name = each.value.records.zone_name

  records = [
    {
      name    = each.key
      type    = each.value.records.type
      ttl     = each.value.records.ttl
      records = each.value.records.record
    }
  ]
}
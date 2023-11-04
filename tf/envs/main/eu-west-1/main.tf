module "oracle" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-rds"

  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = module.vpc.vpc_cidr_block
  subnet_ids            = concat(module.vpc.private_subnets, [module.vpc.public_subnets[0]]) # we should remove from public subnet
  db_class              = "db.r5.4xlarge"
  db_identifier         = "prod-gr-daily-deals"
  db_name               = "DEVOPSPRDDB"
  db_port               = 1521
  engine_version        = "19.0.0.0.ru-2022-04.rur-2022-04.r1"
  engine                = "oracle-se2"
  parameter_group_name  = "default.oracle-se2-19"
  license_model         = "license-included"
  multi_az              = true
  copy_tags_to_snapshot = false
  username              = "awsuser"
  option_group_name     = "statspack-19c"
  allocated_storage     = 3000
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::123456789876:role/rds-monitoring-role"
  allow_cidr            = ["xxxx/32", "xxxx/24", "xxxx/22", "xxxx/21", "xxxx/21", "xxxx/24", "xxxx/16", "xxxx/23", "xxxx/24", "xxxx/32"]
  tags                  = merge(tomap({ "Name" = "vpc-devops-prod-oracle-db" }), var.tags)
}

module "main-mysql" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-rds"

  vpc_id                          = module.vpc.vpc_id
  vpc_cidr                        = module.vpc.vpc_cidr_block
  subnet_ids                      = concat(module.vpc.private_subnets, [module.vpc.public_subnets[0]]) # we should remove from public subnet
  db_class                        = "db.r5.xlarge"
  db_identifier                   = "prod-gr-main-mysql"
  db_name                         = ""
  db_port                         = 3306
  engine_version                  = "8.0.33"
  engine                          = "mysql"
  parameter_group_name            = "dev-mysql-parameters"
  license_model                   = "general-public-license"
  multi_az                        = true
  username                        = "awsuser"
  option_group_name               = "default:mysql-8-0"
  allocated_storage               = 150
  monitoring_interval             = 60
  monitoring_role_arn             = "arn:aws:iam::123456789876:role/rds-monitoring-role"
  allow_cidr                      = ["xxxx/22", "xxxx/23", "xxxx/22", "xxxx/32", "xxxx/24", "xxxx/23", "xxxx/21", "xxxx/24", "xxxx/32"]
  iops                            = 3000
  storage_encrypted               = true
  deletion_protection             = true
  auto_minor_version_upgrade      = true
  create_parameter_group          = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  db_parameter_group_name         = "dev-mysql-parameters"
  family                          = "mysql8.0"

  parameters = [
    {
      name         = "binlog_checksum"
      value        = "NONE"
      apply_method = "immediate"
    },
    {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "immediate"
    },
    {
      name         = "binlog_row_image"
      value        = "full"
      apply_method = "immediate"
    },
    {
      name         = "character_set_client"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_connection"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_database"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_results"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_server"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "log_bin_trust_function_creators"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  tags = merge(tomap({ "Name" = "prod-gr-main-mysql", "workload-type" = "production" }), var.tags)
}

module "testrail-mysql" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-rds"

  vpc_id                       = "vpc-xxxx"
  vpc_cidr                     = "xxxx/19"
  subnet_ids                   = ["subnet-xxxx", "subnet-xxxx"]
  db_class                     = "db.t3.medium"
  db_identifier                = "int-devops-mysql-testrail-db"
  db_name                      = ""
  db_port                      = 3306
  engine_version               = "5.7.42"
  engine                       = "mysql"
  parameter_group_name         = "default.mysql5.7-db-4j7g2mh6lsxr6fovy5dmvchpf4-upgrade"
  license_model                = "general-public-license"
  multi_az                     = false
  username                     = "awsuser"
  option_group_name            = "default:mysql-5-7-db-4j7g2mh6lsxr6fovy5dmvchpf4-upgrade"
  allocated_storage            = 300
  allow_cidr                   = ["xxxx/32", "xxxx/32"]
  auto_minor_version_upgrade   = true
  copy_tags_to_snapshot        = false
  performance_insights_enabled = false
  tags                         = merge(tomap({ "Name" = "int-devops-mysql-testrail-db" }), var.tags)
}

module "redshift" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-redshift"

  cluster_identifier                  = "devops-redshift-${var.environment}"
  subnet_group_name                   = "redshift-sn"
  database_name                       = "devopsrshiftprod"
  environment                         = var.environment
  master_username                     = "awsuser"
  node_type                           = "ds2.xlarge"
  cluster_type                        = "multi-node"
  automated_snapshot_retention_period = "10"
  number_of_nodes                     = "2"
  publicly_accessible                 = "false"
  skip_final_snapshot                 = "true"
  vpc_id                              = module.vpc.vpc_id
  subnet_ids                          = [module.vpc.private_subnets[0]]
  full_access_cidrs                   = concat(var.office_private_cidr, var.gateway_cidr, var.openvpn_server_cidr, var.redshift_cidr, [module.vpc.vpc_cidr_block], [var.vpc_cidr_int], [var.vpc_cidr_bi])
  tags                                = var.tags
}

module "sqs" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-sqs"
  for_each = var.sqs

  create_policy             = try(each.value.create_policy, false)
  sqs_queue_name            = each.key
  sqs_queue_policy          = try(each.value.sqs_queue_policy, null)
  delay_seconds             = try(each.value.delay_seconds, null)
  message_retention_seconds = try(each.value.message_retention_seconds, null)
  max_message_size          = try(each.value.max_message_size, null)
}

module "sns-topic" {
  source   = "git@bitbucket.org:devopsdevops/global-modules.git//devops-sns/cloudposse"
  for_each = var.sns_topics

  name                  = each.key
  subscribers           = try(each.value.subscribers, {})
  sns_topic_policy_json = templatefile(("${path.module}/policies/sns_policy.json.tpl"), { topic_name = each.key })
  kms_master_key_id     = try(each.value.kms_master_key_id, null)
  tags                  = var.tags
}

module "ec2-data-pipeline" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-single-instance"

  instance_count    = 1
  hostname          = "devops-${var.environment}-data-pipeline"
  ami               = "ami-572136bd"
  instance_type     = "t2.xlarge"
  subnet_id         = "subnet-xxxx"
  key_name          = "devops"
  vpc_id            = module.vpc.vpc_id
  env_pem           = "~/.ssh/devops.pem"
  environment       = var.environment
  private_zone_id   = "xxxx"
  full_access_cidrs = concat(var.jenkins_cidr, var.office_private_cidr, var.gateway_cidr, var.openvpn_server_cidr, var.unknown_cidr, [module.vpc.vpc_cidr_block], [var.vpc_cidr_int], [var.vpc_cidr_ecs])
  tags              = var.tags
}

module "ec2-ftp" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-single-instance"

  instance_count    = 1
  hostname          = "devops-${var.environment}-ftp"
  ami               = "ami-49006230"
  instance_type     = "t2.small"
  subnet_id         = "subnet-xxxx"
  key_name          = "devops"
  vpc_id            = module.vpc.vpc_id
  env_pem           = "~/.ssh/devops.pem"
  environment       = var.environment
  private_zone_id   = "xxxx"
  full_access_cidrs = concat(var.jenkins_cidr, var.office_private_cidr, var.gateway_cidr, var.openvpn_server_cidr, var.unknown_cidr, [module.vpc.vpc_cidr_block], [var.vpc_cidr_int], [var.vpc_cidr_ecs])
  tags              = var.tags
}

# PEERING REQUESTS
module "vpc-peering-requestor-green" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-requestor"

  for_each               = var.peering_requests_green
  vpc_id                 = module.vpc.vpc_id
  peer_owner_id          = each.value.peer_owner_id
  peer_vpc_id            = each.value.peer_vpc_id
  peer_region            = each.value.peer_region
  name                   = each.key
  route_table_ids        = setunion(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  destination_cidr_block = each.value.destination_cidr_block
}

module "vpc-peering-requestor-green-ecs" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-requestor"

  for_each               = var.peering_requests_green_ecs
  vpc_id                 = var.vpc_id_ecs
  peer_owner_id          = each.value.peer_owner_id
  peer_vpc_id            = each.value.peer_vpc_id
  peer_region            = each.value.peer_region
  name                   = each.key
  route_table_ids        = ["rtb-00d81d316f28f0186", "rtb-0b78e6973fb1c6e77", "rtb-058fd32614426722b"]
  destination_cidr_block = each.value.destination_cidr_block
}

module "vpc-peering-requestor-ci" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-requestor"

  for_each               = var.peering_requests_ci
  vpc_id                 = module.vpc_ci.vpc_id
  peer_owner_id          = each.value.peer_owner_id
  peer_vpc_id            = each.value.peer_vpc_id
  peer_region            = each.value.peer_region
  name                   = each.key
  route_table_ids        = setunion(module.vpc_ci.private_route_table_ids, module.vpc_ci.public_route_table_ids)
  destination_cidr_block = each.value.destination_cidr_block
}

# PEERING ACCEPT
module "vpc-peering-acceptor-green" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-acceptor"

  for_each                  = var.peering_accept_green
  vpc_peering_connection_id = each.value.pcx_id
  route_table_ids           = setunion(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  destination_cidr_block    = each.value.destination_cidr_block
  name                      = each.key
}

module "vpc-peering-acceptor-ci" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-acceptor"

  for_each                  = var.peering_accept_ci
  vpc_peering_connection_id = each.value.pcx_id
  route_table_ids           = setunion(module.vpc_ci.private_route_table_ids, module.vpc_ci.public_route_table_ids)
  destination_cidr_block    = each.value.destination_cidr_block
  name                      = each.key
}

module "vpc-peering-acceptor-dev-int" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-acceptor"

  for_each                  = var.peering_accept_dev_int
  vpc_peering_connection_id = each.value.pcx_id
  route_table_ids           = ["rtb-2124eb45", "rtb-32385657", "rtb-b034dcd5"]
  destination_cidr_block    = each.value.destination_cidr_block
  name                      = each.key
}

module "vpc-peering-acceptor-common" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-vpc-peering-acceptor"

  for_each                  = var.peering_accept_common
  vpc_peering_connection_id = each.value.pcx_id
  route_table_ids           = ["rtb-47385622"]
  destination_cidr_block    = each.value.destination_cidr_block
  name                      = each.key
}
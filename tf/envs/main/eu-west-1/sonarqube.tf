# RDS RESOURCES
module "postgresql_sonarqube" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-rds"

  vpc_id                      = module.vpc_ci.vpc_id
  vpc_cidr                    = module.vpc_ci.vpc_cidr_block
  subnet_ids                  = module.vpc_ci.private_subnets
  db_class                    = "db.t3.medium"
  db_identifier               = "sonarqube"
  db_name                     = "sonarqube"
  db_port                     = 5432
  engine_version              = "14.8"
  engine                      = "postgres"
  auto_minor_version_upgrade  = "false"
  copy_tags_to_snapshot       = "true"
  multi_az                    = false
  license_model               = "postgresql-license"
  storage_encrypted           = true
  option_group_name           = "default:postgres-14"
  parameter_group_name        = "default.postgres14"
  allocated_storage           = 30
  username                    = "sonarqube_user"
  manage_master_user_password = true
  allow_cidr                  = ["10.65.72.0/22", "10.249.96.250/32"]
  tags                        = merge(tomap({ "Name" = "sonarqube-db" }), var.tags)
}

# LOAD BALANCER RESOURCES
resource "aws_security_group" "security_group_access_to_internal_ci_alb" {
  name        = "${var.environment_ci}-internal-alb-sg"
  description = "Provides access to the CI Internal LB."

  vpc_id = module.vpc_ci.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow on port 443 from VPC"
    cidr_blocks = [module.vpc_ci.vpc_cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow on port 443 from office"
    cidr_blocks = var.office_private_cidr
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow on port 443 from VPN"
    cidr_blocks = var.openvpn_server_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.environment_ci}-internal-ci-alb-sg" }), var.tags)
}

module "internal-ci-alb" {
  source                    = "git@bitbucket.org:devopsdevops/global-modules.git//devops-lb/common-lb"
  alb_name                  = "internal"
  environment               = var.environment_ci
  vpc_id                    = module.vpc_ci.vpc_id
  subnets_id                = module.vpc_ci.private_subnets
  is_internal               = true
  create_aws_security_group = false

  additional_sgs = [
    aws_security_group.security_group_access_to_internal_ci_alb.id,
  ]

  tags = var.tags
}

# ECS RESOURCES
resource "aws_security_group" "security_group_ecs" {
  name        = "${var.environment_ci}-ecs-service-sg"
  description = "Provides access to the ECS service on port 9000."

  vpc_id = module.vpc_ci.vpc_id

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    description     = "Allow on port 9000 from LB"
    security_groups = [aws_security_group.security_group_access_to_internal_ci_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.environment_ci}-ecs-service-sg" }), var.tags)
}

module "ecs_service_sonarqube" {
  source                            = "git@bitbucket.org:devopsdevops/global-modules.git//devops-ecs"
  container_name                    = "sonarqube-container"
  image_name                        = "123456789876.dkr.ecr.eu-west-1.amazonaws.com/sonarqube"
  image_tag                         = "latest"
  fluentbit_image                   = "123456789876.dkr.ecr.eu-west-1.amazonaws.com/devops/fluent-bit:latest"
  task_cpu                          = 2048
  task_memory                       = 8192
  container_cpu                     = 2048
  container_memory_reservation      = 4096
  container_memory                  = 4096
  environment_variables             = local.sonarqube_env_variables
  secrets                           = local.sonarqube_secret_variables
  container_protocol                = "HTTP"
  container_port                    = 9000
  environment                       = var.environment_ci
  environment_number                = "01"
  task_execution_role_arn           = "arn:aws:iam::123456789876:role/JenkinsSlavesEcsTasksExecutionRole"
  service_name                      = "sonarqube"
  cluster_arn                       = "arn:aws:ecs:eu-west-1:123456789876:cluster/devops-production-01"
  health_check_grace_period_seconds = 30
  security_groups                   = [aws_security_group.security_group_ecs.id]
  private_subnets                   = module.vpc_ci.private_subnets
  cloudwatch_logs_enabled           = false
  enable_autoscaling                = true
  max_capacity                      = 10
  min_capacity                      = 1
  desired_count                     = 1
  cluster_name                      = "devops-production-01"
  target_tracking_policy            = tolist([var.cpu_autoscaling_policy, var.memory_autoscaling_policy])
  ecs_autoscaling_role_arn          = "arn:aws:iam::123456789876:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  vpc_id                            = module.vpc_ci.vpc_id
  health_check_matcher              = "200"
  health_check_path                 = "/"
  efs_volume_id                     = aws_efs_file_system.sonarqube_efs.id
  mount_points                      = local.mount_points_sonarqube
  health_check_default_enabled      = false
  listener_arns = [
    {
      "listener_arn" = module.internal-ci-alb.listener_443_arn
      "target_url"   = ""
    },
  ]
  listeners_count = 1
  create_alarm    = true
  alb_arn_suffix  = module.internal-ci-alb.arn_suffix
  alb_dns_name    = module.internal-ci-alb.alb_dns_name
  splunk_token    = "xxxx"
  splunk_index    = "prod-apps"
}

module "ecs_service_sonarqube_java8" {
  source                            = "git@bitbucket.org:devopsdevops/global-modules.git//devops-ecs"
  container_name                    = "sonarqube-java8-container"
  image_name                        = "123456789876.dkr.ecr.eu-west-1.amazonaws.com/sonarqube-java8"
  image_tag                         = "latest"
  fluentbit_image                   = "123456789876.dkr.ecr.eu-west-1.amazonaws.com/devops/fluent-bit:latest"
  task_cpu                          = 2048
  task_memory                       = 8192
  container_cpu                     = 2048
  container_memory_reservation      = 4096
  container_memory                  = 4096
  environment_variables             = local.sonarqube_env_variables
  secrets                           = local.sonarqube_java8_secret_variables
  container_protocol                = "HTTP"
  container_port                    = 9000
  environment                       = var.environment_ci
  environment_number                = "01"
  task_execution_role_arn           = "arn:aws:iam::123456789876:role/JenkinsSlavesEcsTasksExecutionRole"
  service_name                      = "sonarqube-java8"
  cluster_arn                       = "arn:aws:ecs:eu-west-1:123456789876:cluster/devops-production-01"
  health_check_grace_period_seconds = 30
  security_groups                   = [aws_security_group.security_group_ecs.id]
  private_subnets                   = module.vpc_ci.private_subnets
  cloudwatch_logs_enabled           = false
  enable_autoscaling                = true
  max_capacity                      = 10
  min_capacity                      = 1
  desired_count                     = 1
  cluster_name                      = "devops-production-01"
  target_tracking_policy            = tolist([var.cpu_autoscaling_policy, var.memory_autoscaling_policy])
  ecs_autoscaling_role_arn          = "arn:aws:iam::123456789876:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  vpc_id                            = module.vpc_ci.vpc_id
  health_check_matcher              = "200"
  health_check_path                 = "/"
  efs_volume_id                     = aws_efs_file_system.sonarqube_java8_efs.id
  mount_points                      = local.mount_points_sonarqube_java8
  health_check_default_enabled      = false
  listener_arns = [
    {
      "listener_arn" = module.internal-ci-alb.listener_443_arn
      "target_url"   = ""
    },
  ]
  listeners_count = 1
  create_alarm    = true
  alb_arn_suffix  = module.internal-ci-alb.arn_suffix
  alb_dns_name    = module.internal-ci-alb.alb_dns_name
  splunk_token    = "xxxx"
  splunk_index    = "prod-apps"
}

# LOCALS
locals {
  ulimits = [
    {
      name      = "nofile"
      softLimit = 131072
      hardLimit = 131072
    },
    {
      name      = "nproc"
      softLimit = 8192
      hardLimit = 8192
    }
  ]
  sonarqube_env_variables = [
    {
      name  = "environment"
      value = "${var.environment_ci}"
    },
    {
      name  = "environment_name"
      value = "${var.environment_ci}"
    },
    {
      name  = "port"
      value = "9000"
    },
    {
      name  = "SONAR_SEARCH_JAVAADDITIONALOPTS"
      value = "-Dnode.store.allow_mmap=false,-Ddiscovery.type=single-node"
    }
  ]

  sonarqube_secret_variables = [
    {
      name      = "SONAR_JDBC_USERNAME"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789876:parameter/ci/sonarqube/secret/SONAR_JDBC_USERNAME"
    },
    {
      name      = "SONAR_JDBC_PASSWORD"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789876:parameter/ci/sonarqube/secret/SONAR_JDBC_PASSWORD"
    },
    {
      name      = "SONAR_JDBC_URL"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789876:parameter/ci/sonarqube/secret/SONAR_JDBC_URL"
    }
  ]

  sonarqube_java8_secret_variables = [
    {
      name      = "SONAR_JDBC_USERNAME"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789876:parameter/ci/sonarqube/secret/SONAR_JDBC_USERNAME"
    },
    {
      name      = "SONAR_JDBC_PASSWORD"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789876:parameter/ci/sonarqube/secret/SONAR_JDBC_PASSWORD"
    },
    {
      name      = "SONAR_JDBC_URL"
      valueFrom = "arn:aws:ssm:eu-west-1:123456789876:parameter/ci/sonarqube-java8/secret/SONAR_JDBC_URL"
    }
  ]

  r53_devdevops_co_uk_simple = [
    {
      name = "sonarqube"
      }, {
      name = "sonarqube-java8"
    }
  ]

  mount_points_sonarqube = [
    {
      sourceVolume  = "ci-sonarqube-efs"
      containerPath = "/opt/sonarqube/data"
      readOnly      = "false"
    }
  ]

  mount_points_sonarqube_java8 = [
    {
      sourceVolume  = "ci-sonarqube-java8-efs"
      containerPath = "/opt/sonarqube-java8/data"
      readOnly      = "false"
    }
  ]
}

# ROUTE53 RESOURCES
resource "aws_route53_record" "r53_devdevops_co_uk_simple" {
  for_each = { for r in local.r53_devdevops_co_uk_simple : r.name => r }

  zone_id = var.r53_devdevops_co_uk
  name    = each.value.name
  type    = try(each.value.type, "CNAME")
  ttl     = try(each.value.ttl, 5)
  records = try(each.value.records, [module.internal-ci-alb.alb_dns_name])
}

# EFS SECURITY GROUP RESOURCES
resource "aws_security_group" "security_group_efs" {
  name        = "${var.environment_ci}-efs-sg"
  description = "Provides access to the EFS resources on port 2049."

  vpc_id = module.vpc_ci.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    description = "Allow on port 2049"
    cidr_blocks = [module.vpc_ci.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.environment_ci}-efs-sg" }), var.tags_ci)
}

#SONARQUBE EFS
resource "aws_efs_file_system" "sonarqube_efs" {
  creation_token   = "sonarqube_efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  encrypted        = "true"
  tags             = merge(tomap({ "Name" = "${var.environment_ci}-sonarqube-efs" }), var.tags_ci)
}

resource "aws_efs_backup_policy" "sonarqube_policy" {
  file_system_id = aws_efs_file_system.sonarqube_efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "sonarqube_efs-mt" {
  count           = length(module.vpc_ci.public_subnets)
  file_system_id  = aws_efs_file_system.sonarqube_efs.id
  subnet_id       = element(module.vpc_ci.public_subnets, count.index)
  security_groups = [aws_security_group.security_group_efs.id]
}

#SONARQUBE_JAVA8 EFS
resource "aws_efs_file_system" "sonarqube_java8_efs" {
  creation_token   = "sonarqube_java8_efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  encrypted        = "true"
  tags             = merge(tomap({ "Name" = "${var.environment_ci}-sonarqube-java8-efs" }), var.tags_ci)
}

resource "aws_efs_backup_policy" "sonarqube_java8_policy" {
  file_system_id = aws_efs_file_system.sonarqube_java8_efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "sonarqube_java8_efs-mt" {
  count           = length(module.vpc_ci.public_subnets)
  file_system_id  = aws_efs_file_system.sonarqube_java8_efs.id
  subnet_id       = element(module.vpc_ci.public_subnets, count.index)
  security_groups = [aws_security_group.security_group_efs.id]
}
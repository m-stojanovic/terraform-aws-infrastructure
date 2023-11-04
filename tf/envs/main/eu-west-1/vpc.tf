# VPC GEEN
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name                  = "devops-green-01"
  cidr                  = var.vpc_cidr
  secondary_cidr_blocks = [var.vpc_cidr_secondary]

  azs = [
    "eu-west-1a",
    "eu-west-1b",
  ]
  private_subnets = [
    "10.249.144.0/22",
    "10.249.148.0/22",
  ]
  public_subnets = [
    "10.249.152.0/21",
    "10.249.142.0/23",
  ]

  map_public_ip_on_launch              = true
  enable_nat_gateway                   = true
  enable_vpn_gateway                   = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  amazon_side_asn                      = 9059
  default_route_table_propagating_vgws = ["vgw-ef211e9b"]
  default_network_acl_ingress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    }
  ]
  default_network_acl_egress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    }
  ]

  tags = var.tags
}

# resource "aws_security_group" "security_group_vpc_endpoints" {
#   name        = "${var.environment}-vpc-endpoints-sg"
#   description = "Security group to allow access to VPC endpoints"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     description = "allow access from VPC CIDRs"
#     cidr_blocks = concat([module.vpc.vpc_cidr_block], module.vpc.vpc_secondary_cidr_blocks)
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     description = "allow external access to everywhere"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(tomap({ "Name" = "${var.environment}-vpc-endpoints-sg" }), var.tags)

# }

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = "arn:aws:s3:::green-vpc-logs-s3"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
}

resource "aws_vpc_endpoint" "s3-ecs" {
  vpc_id            = var.vpc_id_ecs
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids_ecs
}

resource "aws_vpc_endpoint" "s3-ci" {
  vpc_id            = module.vpc_ci.vpc_id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc_ci.private_route_table_ids
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ecr.api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "ecr-api-ecs" {
  vpc_id              = var.vpc_id_ecs
  service_name        = "com.amazonaws.eu-west-1.ecr.api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "ecr-api-ci" {
  vpc_id              = module.vpc_ci.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ecr.api"
  private_dns_enabled = false
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ecr.dkr"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "ecr-dkr-ecs" {
  vpc_id              = var.vpc_id_ecs
  service_name        = "com.amazonaws.eu-west-1.ecr.dkr"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "ecr-dkr-ci" {
  vpc_id              = module.vpc_ci.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ecr.dkr"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "autoscaling" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.autoscaling"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "execute-api-ecs" {
  vpc_id              = var.vpc_id_ecs
  service_name        = "com.amazonaws.eu-west-1.execute-api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "execute-api-dev" {
  vpc_id              = module.vpc_dev.vpc_id
  service_name        = "com.amazonaws.eu-west-1.execute-api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

resource "aws_vpc_endpoint" "elasticsearch-connect" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.vpce.eu-west-1.vpce-svc-01f2afe87944eb12b"
  private_dns_enabled = false
  vpc_endpoint_type   = "Interface"
  tags                = merge(tomap({ "Name" = "connect-es-from-prod-private-subnet" }), var.tags)
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ec2"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
}

# VPC CI

module "vpc_ci" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  name    = "devops-ci"
  cidr    = var.vpc_cidr_ci

  azs = [
    "eu-west-1a",
    "eu-west-1b",
  ]
  private_subnets = [
    "10.249.162.0/25",
    "10.249.162.128/25",
  ]
  public_subnets = [
    "10.249.163.0/25",
    "10.249.163.128/25",
  ]

  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  enable_vpn_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  amazon_side_asn         = 9059
  default_network_acl_ingress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    }
  ]
  default_network_acl_egress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    }
  ]

  tags = var.tags_ci
}

resource "aws_flow_log" "vpc-flow-logs-ci" {
  traffic_type         = "ALL"
  iam_role_arn         = "arn:aws:iam::123456789876:role/CloudwatchLogsRole"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc-log-group.arn
  vpc_id               = module.vpc_ci.vpc_id
}

resource "aws_cloudwatch_log_group" "vpc-log-group" {
  name              = "/vpc-flow-logs/${module.vpc_ci.vpc_id}"
  retention_in_days = "180"

  tags = {
    VPC  = module.vpc_ci.vpc_id
    Type = "Flow Logs"
  }
}

resource "aws_vpn_connection" "vpn-ci-to-asa" {
  customer_gateway_id = "cgw-6825181c"
  type                = "ipsec.1"
  vpn_gateway_id      = module.vpc_ci.vgw_id
  static_routes_only  = true

  tags = merge(tomap({ "Name" = "ci-vpc-to-ipsec-ASAv" }), var.tags)
}

# WORKING FOR ROUTE CREATION, UNCOMMENT AT FIRST REQUIREMENT TO CREATE NEW ROUTE
resource "aws_route" "routes" {
  for_each = local.routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = try(each.value.destination_cidr_block, null)
  gateway_id             = try(each.value.gateway_id, null)
}

locals {
  routes = {
    # "route1" = {
    #   route_table_id         = element(module.vpc_ci.private_route_table_ids, 0)
    #   destination_cidr_block = "10.80.0.0/16" # pulse_cidr
    #   gateway_id             = module.vpc_ci.vgw_id
    # },
    # "route2" = {
    #   route_table_id         = element(module.vpc_ci.private_route_table_ids, 1)
    #   destination_cidr_block = "10.80.0.0/16" # pulse_cidr
    #   gateway_id             = module.vpc_ci.vgw_id
    # }
  }
}

# UKNOWN
# resource "aws_vpn_connection_route" "vpn-routes" {
#   for_each = var.static_routes

#   destination_cidr_block = each.value.destination_cidr_block
#   vpn_connection_id      = try(each.value.vpn_connection_id, aws_vpn_connection.vpn-ci-to-asa.id)
# }

# Recreate routes after VPC apply - correct routes as well
# variable "static_routes" {
#   type = map(object({
#     destination_cidr_block = string
#   }))
#   default = {
#     "route1" = {
#       destination_cidr_block = "10.63.0.0/16"
#     },
#     "route2" = {
#       destination_cidr_block = "10.80.0.0/16"
#     },
#     "route3" = {
#       destination_cidr_block = "10.65.60.0/24"
#     },
#     "route4" = {
#       destination_cidr_block = "10.65.72.0/22"
#     }
#   }
# }

# DEV VPC
module "vpc_dev" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "devops-dev-01"
  cidr = var.vpc_cidr_dev

  azs = [
    "eu-west-1a",
    "eu-west-1b",
  ]
  private_subnets = [
    "10.249.21.0/25",
    "10.249.21.128/25",
  ]
  public_subnets = [
    "10.249.20.0/24",
  ]

  default_route_table_propagating_vgws = ["vgw-4ddee139"]
  map_public_ip_on_launch              = true
  enable_nat_gateway                   = false
  enable_vpn_gateway                   = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  amazon_side_asn                      = 9059
  default_network_acl_ingress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    }
  ]
  default_network_acl_egress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    }
  ]

  tags = var.tags_dev01
}
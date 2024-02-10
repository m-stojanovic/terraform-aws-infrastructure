aws_account_id     = "123456789876"
environment        = "prod-gr"
environment_ci     = "ci"
vpc_id_ecs         = "vpc-"
vpc_cidr           = ""
vpc_cidr_secondary = ""
vpc_cidr_ci        = ""
vpc_cidr_ecs       = ""
vpc_cidr_dev       = ""
vpc_cidr_common    = ""
vpc_cidr_int       = "/19"
vpc_cidr_bi        = ""

route_table_ids_ecs = ["rtb-0b78e6973fb1c6e77", "rtb-058fd32614426722b"]
office_private_cidr = ["/16", "/16", ""]
jenkins_cidr        = [""]
gateway_cidr        = ["10.249.95.10/32", "10.249.163.105/32"]
openvpn_server_cidr = ["10.249.96.250/32", "52.215.241.136/32"]
redshift_cidr       = ["52.18.80.118/32", "54.194.153.56/32", "10.249.70.29/32", ""]
unknown_cidr        = ["34.243.84.243/32", "34.244.156.251/32", "34.244.222.179/32", "34.244.3.15/32", "34.244.90.197/32", "34.246.180.223/32", "34.247.92.6/32", "34.249.239.215/32", "52.208.152.67/32", "54.194.180.108/32", "54.229.124.1/32", ""]

# sonarqube variables
r53_devdevops_co_uk = "Z2MONX8ELB3DL5"
cpu_autoscaling_policy = {
  name                   = "cpu_api_scaling"
  target_value           = "90"
  scale_in_cooldown      = "120"
  scale_out_cooldown     = "120"
  predefined_metric_type = "ECSServiceAverageCPUUtilization"
}
memory_autoscaling_policy = {
  name                   = "memory_scaling"
  target_value           = "90"
  scale_in_cooldown      = "120"
  scale_out_cooldown     = "120"
  predefined_metric_type = "ECSServiceAverageMemoryUtilization"
}

# PEERINGS
peering_requests_green = {
  vpc-green-to-vpc-ci-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = ""
    peer_region            = "eu-west-1"
  }
  vpc-green-to-vpc-bi-tooling-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "587854172176"
    destination_cidr_block = "/16"
    peer_region            = "eu-west-1"
  }
  vpc-green-to-vpc-dev-int-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = "/19"
    peer_region            = "eu-west-1"
  }
  vpc-green-to-vpc-common-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = ""
    peer_region            = "eu-west-1"
  }
}

peering_requests_green_ecs = {
  vpc-green-ecs-to-vpc-green-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = ""
    peer_region            = "eu-west-1"
  }
  vpc-green-ecs-to-vpc-ci-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = ""
    peer_region            = "eu-west-1"
  }
  vpc-green-ecs-to-vpc-common-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = ""
    peer_region            = "eu-west-1"
  }
  vpc-green-ecs-to-vpc-dev-int-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = "/19"
    peer_region            = "eu-west-1"
  }
}

peering_requests_ci = {
  vpc-ci-to-vpc-dev-int-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = "/19"
    peer_region            = "eu-west-1"
  }
  vpc-ci-to-vpc-common-eu-west-1 = {
    peer_vpc_id            = "vpc-"
    peer_owner_id          = "123456789876"
    destination_cidr_block = ""
    peer_region            = "eu-west-1"
  }
}

peering_accept_green = {
  vpc-green-from-vpc-bi = {
    pcx_id                 = "pcx-06b7921948c5e45a3"
    destination_cidr_block = ""
  }
}

peering_accept_ci = {
  vpc-ci-from-vpc-bi = {
    pcx_id                 = "pcx-07b0b0718948a58ea"
    destination_cidr_block = ""
  }
  vpc-ci-from-vpc-development = {
    pcx_id                 = "pcx-0cc66bbf3161cce8d"
    destination_cidr_block = ""
  }
  vpc-ci-from-vpc-nxt = {
    pcx_id                 = "pcx-031ed7a8ae8522d96"
    destination_cidr_block = ""
  }
}

peering_accept_dev_int = {
  vpc-dev-int-from-vpc-bi = {
    pcx_id                 = "pcx-0af4896f42b928c9d"
    destination_cidr_block = ""
  }
  vpc-dev-int-from-vpc-development = {
    pcx_id                 = "pcx-0f423322dda56f477"
    destination_cidr_block = ""
  }
  vpc-dev-int-from-vpc-nxt = {
    pcx_id                 = "pcx-09b3246ffb4b46d2e"
    destination_cidr_block = ""
  }
  vpc-dev-int-from-vpc-common = {
    pcx_id                 = "pcx-283ff941"
    destination_cidr_block = ""
  }
  vpc-dev-int-from-vpc-prod = {
    pcx_id                 = "pcx-3a15f753"
    destination_cidr_block = ""
  }
  vpc-dev-int-from-vpc-dev-01 = {
    pcx_id                 = "pcx-cf99bfa6"
    destination_cidr_block = ""
  }
}

peering_accept_common = {
  vpc-common-from-vpc-bi = {
    pcx_id                 = "pcx-096b022167187c018"
    destination_cidr_block = ""
  }
  vpc-common-from-vpc-development = {
    pcx_id                 = "pcx-0fd6509d1e485142d"
    destination_cidr_block = ""
  }
  vpc-common-from-vpc-nxt = {
    pcx_id                 = "pcx-0860bada540f991ce"
    destination_cidr_block = ""
  }
  vpc-common-from-vpc-dev-01 = {
    pcx_id                 = "pcx-3463425d"
    destination_cidr_block = ""
  }
  vpc-common-from-vpc-bi-tooling = {
    pcx_id                 = "pcx-0e71ff316f544ce91"
    destination_cidr_block = "/16"
  }
}

tags = {
  "created-by" = "terraform"
  "env"        = "prod"
  "vpc"        = "devops-green-01"
  "org"        = "devops"
  "team"       = "devops"
}

tags_ci = {
  "created-by" = "terraform"
  "env"        = "prod"
  "vpc"        = "devops-ci"
  "org"        = "devops"
  "team"       = "devops"
}

tags_dev01 = {
  "created-by" = "terraform"
  "env"        = "prod"
  "vpc"        = "devops-dev-01"
  "org"        = "devops"
  "team"       = "devops"
}

sns_topics = {
  prod-gr-living-social-subscription = {
    subscribers = {
      rule_1 = {
        protocol               = "sqs"
        endpoint               = "arn:aws:sqs:eu-west-1:123456789876:prod-gr-subscription"
        endpoint_auto_confirms = true
        raw_message_delivery   = false
      }
    }
  }
  prod-gr-error = {
    subscribers = {
      rule_1 = {
        protocol               = "sqs"
        endpoint               = "arn:aws:sqs:eu-west-1:123456789876:prod-gr-error"
        endpoint_auto_confirms = true
        raw_message_delivery   = false
      }
    }
  }
  prod-gr-cybersource-transaction-error = {
    subscribers = {
      rule_1 = {
        protocol               = "sqs"
        endpoint               = "arn:aws:sqs:eu-west-1:123456789876:prod-gr-transaction-error"
        endpoint_auto_confirms = true
        raw_message_delivery   = false
      }
    }
  }
}


sqs = {
  "ProductionLogs" = {},
  "prod-gr-auto-subscription" = {
    message_retention_seconds = 1209600
    delay_seconds             = 300
  }
  "prod-gr-post-update" = {
    delay_seconds = 60
  },
  "prod-gr-dealVoucherHit" = {
    message_retention_seconds = 14440
  },
  "prod-gr-viewDeal" = {
    message_retention_seconds = 14440
  },
  "prod-gr-expiry-reminder-devops-email" = {},
  "prod-gr-shareDeal" = {
    message_retention_seconds = 1209600
  },
  "prod-gr-socialReferralJob" = {
    message_retention_seconds = 1209600
  },
  "prod-gr-subscription" = {
    message_retention_seconds = 1209600
  },
  "prod-gr-unsubscription" = {
    message_retention_seconds = 1209600
  }
}

load_balancer_target_groups = {
  "prod-gr-dac" = {
    lb = "app/prod-gr-internal-alb/"
    tg = "targetgroup/ls-prod-gr-dac/"
  }
  "ls-prod-gr-payment" = {
    tg = "targetgroup/ls-prod-gr-payment/"
  }
  "ls-prod-gr-sailthru-batch" = {
    lb = "app/prod-gr-internal-alb/"
    tg = "targetgroup/ls-prod-gr-sailthru-batch/"
  }
  "prod-gr-affiliate-email" = {
    lb = "app/prod-gr-internal-alb/"
    tg = "targetgroup/prod-gr-affiliate-email/"
  }
  "prod-gr-affiliate-email-api" = {
    lb = "app/prod-gr-internal-alb/"
    tg = "targetgroup/prod-gr-affiliate-email-api/"
  }
}

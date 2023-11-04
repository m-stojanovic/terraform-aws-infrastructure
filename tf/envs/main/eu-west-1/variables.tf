variable "aws_account_id" {}
variable "environment" {}
variable "environment_ci" {}
variable "tags" {}
variable "tags_ci" {}
variable "tags_dev01" {}

variable "vpc_cidr" {}
variable "vpc_cidr_secondary" {}
variable "vpc_cidr_ci" {}
variable "vpc_cidr_ecs" {}
variable "vpc_cidr_dev" {}
variable "vpc_cidr_common" {}
variable "vpc_cidr_int" {}
variable "vpc_cidr_bi" {}
variable "vpc_id_ecs" {}
variable "route_table_ids_ecs" {}
variable "office_private_cidr" {}
variable "jenkins_cidr" {}
variable "gateway_cidr" {}
variable "openvpn_server_cidr" {}
variable "unknown_cidr" {}
variable "redshift_cidr" {}

variable "peering_requests_green" {}
variable "peering_requests_green_ecs" {}
variable "peering_requests_ci" {}
variable "peering_accept_green" {}
variable "peering_accept_ci" {}
variable "peering_accept_dev_int" {}
variable "peering_accept_common" {}

variable "sns_topics" {
  type        = map(any)
  description = "The SNS topic for sns-topic module"
}

variable "sqs" {
  type        = map(any)
  description = "The SQS for sns-topic module"
}

# sonarqube variables
variable "r53_devdevops_co_uk" {}
variable "cpu_autoscaling_policy" {
  type = map(string)
}
variable "memory_autoscaling_policy" {
  type = map(string)
}

#!/bin/bash

queue_names=(
    prod-gr-error
    prod-gr-downloadToolbar
)

for queue_name in "${queue_names[@]}"
do
  terraform_1.3.6 import "module.sns-topic[\"${queue_name}\"].module.sns-topic.aws_sns_topic.this[0]" "arn:aws:sns:eu-west-1:123456789876:${queue_name}"
  #terraform_1.3.6 import "module.sqs[\"${queue_name}\"].aws_sqs_queue.this" "https://sqs.eu-west-1.amazonaws.com/123456789876/${queue_name}"
done


# terraform_1.3.6 import 'module.vpc-peering-requestor-green-ecs["vpc-green-ecs-to-vpc-ci-eu-west-1"].aws_vpc_peering_connection.vpc-peering-requestor' 'pcx-0d289e0d1652d7838'
# terraform_1.3.6 import 'module.vpc-peering-requestor-green-ecs["vpc-green-ecs-to-vpc-ci-eu-west-1"].aws_route.peer-route[0]' 'rtb-xxxx.249.162.0/23'
# terraform_1.3.6 import 'module.vpc-peering-requestor-green-ecs["vpc-green-ecs-to-vpc-ci-eu-west-1"].aws_route.peer-route[1]' 'rtb-xxxx.249.162.0/23'
# terraform_1.3.6 import 'module.vpc-peering-requestor-green-ecs["vpc-green-ecs-to-vpc-ci-eu-west-1"].aws_route.peer-route[2]' 'rtb-xxxx.249.162.0/23'


#terraform_1.3.6 import 'module.vpc-peering-acceptor-common["vpc-common-from-vpc-bi"].aws_vpc_peering_connection_accepter.vpc-peering-acceptter' 'pcx-096b022167187c018'
#terraform_1.3.6 import 'module.vpc-peering-acceptor-common["vpc-common-from-vpc-bi"].aws_route.peer-route[0]' 'rtb-xxxx.249.236.0/24'
#terraform_1.3.6 import 'module.vpc-peering-acceptor-dev-int["vpc-common-from-vpc-dev-01"].aws_route.peer-route[1]' 'rtb-xxxx.249.20.0/23'
#terraform_1.3.6 import 'module.vpc-peering-acceptor-dev-int["vpc-common-from-vpc-dev-01"].aws_route.peer-route[2]' 'rtb-xxxx.249.20.0/23'
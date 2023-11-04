resource "aws_cloudwatch_metric_alarm" "target_group_health_alarm" {
  for_each = var.load_balancer_target_groups

  alarm_name          = "${each.key}-unhealthy-host-alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = try(each.value.evaluation_periods, 1)
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = try(each.value.period, "300")
  statistic           = "Maximum"
  threshold           = try(each.value.threshold, 0)
  alarm_description   = "Triggered when target group health state changes to unhealthy"

  dimensions = {
    LoadBalancer = try(each.value.lb, "app/prod-gr-external-alb/58f76ed2e935efc4")
    TargetGroup  = each.value.tg
  }

  alarm_actions = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  ok_actions    = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
}

variable "load_balancer_target_groups" {
  type    = map(any)
  default = {}
}
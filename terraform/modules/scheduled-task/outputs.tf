output "name" {

    value = aws_cloudwatch_event_rule.event_rule.name
}
output "event_rule_arn" {

    value = aws_cloudwatch_event_rule.event_rule.arn
}
output "task_arn" {

    value = aws_ecs_task_definition.task.arn
}
output "is_enabled" {

    value = aws_cloudwatch_event_rule.event_rule.is_enabled
}

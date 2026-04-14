output "secret_arns" {
  value = { for k, v in aws_secretsmanager_secret.app : k => v.arn }
}

# Ready-to-use format for ECS task definition secrets block
output "ecs_secrets" {
  value = [
    for k, v in aws_secretsmanager_secret.app : {
      name      = upper(replace(k, "-", "_"))
      valueFrom = v.arn
    }
  ]
}

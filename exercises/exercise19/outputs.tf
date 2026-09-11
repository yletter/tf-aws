output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "task_definition_arn" {
  description = "Registered ECS task definition ARN"
  value       = aws_ecs_task_definition.main.arn
}

output "subnet_id" {
  description = "Default VPC subnet used by the run command"
  value       = data.aws_subnets.default.ids[0]
}

output "security_group_id" {
  description = "Default VPC security group used by the run command"
  value       = data.aws_security_group.default.id
}

output "run_task_command" {
  description = "AWS CLI command to run one Fargate task"
  value       = "aws ecs run-task --cluster ${aws_ecs_cluster.main.name} --task-definition ${aws_ecs_task_definition.main.family} --launch-type FARGATE --network-configuration 'awsvpcConfiguration={subnets=[${data.aws_subnets.default.ids[0]}],securityGroups=[${data.aws_security_group.default.id}],assignPublicIp=ENABLED}' --region ${var.aws_region}"
}

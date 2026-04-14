variable "project"                    { type = string }
variable "env"                        { type = string }
variable "aws_region"                 { type = string }
variable "vpc_id"                     { type = string }
variable "public_subnet_ids"          { type = list(string) }
variable "private_subnet_ids"         { type = list(string) }
variable "ecs_task_execution_role_arn" { type = string }
variable "ecs_task_role_arn"          { type = string }
variable "certificate_arn"            { type = string }
variable "container_port"             { type = number; default = 3000 }
variable "health_check_path"          { type = string; default = "/health" }
variable "task_cpu"                   { type = number; default = 256 }
variable "task_memory"                { type = number; default = 512 }
variable "desired_count"              { type = number; default = 1 }
variable "min_capacity"               { type = number; default = 1 }
variable "max_capacity"               { type = number; default = 4 }
variable "environment_variables"      { type = list(map(string)); default = [] }
variable "secrets"                    { type = list(map(string)); default = [] }
variable "tags"                       { type = map(string); default = {} }

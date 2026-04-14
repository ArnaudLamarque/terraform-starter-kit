variable "project"           { type = string }
variable "env"               { type = string }
variable "alert_emails"      { type = list(string) }
variable "log_retention_days"{ type = number; default = 7 }
variable "ecs_cluster_name"  { type = string }
variable "ecs_service_name"  { type = string }
variable "rds_identifier"    { type = string }
variable "alb_arn_suffix"    { type = string }
variable "tags"              { type = map(string); default = {} }

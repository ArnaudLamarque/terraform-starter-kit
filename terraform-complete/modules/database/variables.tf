variable "project"              { type = string }
variable "env"                  { type = string }
variable "vpc_id"               { type = string }
variable "database_subnet_ids"  { type = list(string) }
variable "app_security_group_id" { type = string }
variable "instance_class"       { type = string; default = "db.t3.micro" }
variable "allocated_storage"    { type = number; default = 20 }
variable "db_name"              { type = string }
variable "db_username"          { type = string; default = "admin" }
variable "kms_key_arn"          { type = string; default = null }
variable "tags"                 { type = map(string); default = {} }

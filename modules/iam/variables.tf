variable "project"        { type = string }
variable "env"            { type = string }
variable "github_org"     { type = string }
variable "github_repo"    { type = string }
variable "aws_region"     { type = string }
variable "aws_account_id" { type = string }
variable "tags"           { type = map(string); default = {} }

variable "project"        { type = string }
variable "aws_region"     { type = string }
variable "aws_account_id" { type = string }
variable "github_org"     { type = string }
variable "github_repo"    { type = string }
variable "domain_name"    { type = string }
variable "alert_emails"   { type = list(string) }
variable "app_secrets" {
  type = map(object({
    value       = string
    description = string
  }))
  sensitive = true
  default   = {}
}

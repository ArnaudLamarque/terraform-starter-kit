variable "project" { type = string }
variable "env"     { type = string }
variable "secrets" {
  type = map(object({
    value       = string
    description = string
  }))
  sensitive = true
}
variable "tags" { type = map(string); default = {} }

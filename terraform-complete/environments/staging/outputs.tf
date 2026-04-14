output "app_url"           { value = "https://staging.${var.domain_name}" }
output "alb_dns"           { value = module.compute.alb_dns_name }
output "ecr_repository"    { value = module.compute.ecr_repository_url }
output "db_endpoint"       { value = module.database.endpoint }
output "db_secret_arn"     { value = module.database.secret_arn }
output "cloudfront_domain" { value = module.storage.cloudfront_domain }

output "certificate_arn" { value = aws_acm_certificate_validation.main.certificate_arn }
output "app_fqdn"        { value = aws_route53_record.app.fqdn }

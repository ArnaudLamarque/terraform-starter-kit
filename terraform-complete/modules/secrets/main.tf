# ── App secrets — store all sensitive config here ─────────────────────────────
# Never put secrets in tfvars, env vars, or Docker images.
# Reference these in ECS task definition via the `secrets` block.

resource "aws_secretsmanager_secret" "app" {
  for_each = var.secrets

  name                    = "${var.project}/${var.env}/${each.key}"
  description             = each.value.description
  recovery_window_in_days = var.env == "prod" ? 7 : 0 # Instant delete in dev

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "app" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.app[each.key].id
  secret_string = each.value.value
}

# ── Output map for ECS task definition secrets block ─────────────────────────
# Usage in compute module:
# secrets = module.secrets.ecs_secrets

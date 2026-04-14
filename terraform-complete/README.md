# Terraform Starter Kit — AWS Full Startup Stack

> Built by [Phacet](https://phacet.com) after learning the hard way.
> A production-ready Terraform foundation for dev-led startups on AWS.

---

## What's inside

| Module | What it does |
|--------|-------------|
| `networking` | VPC, public/private/db subnets, NAT gateway, VPC flow logs |
| `iam` | GitHub Actions OIDC, ECS execution role, least-privilege policies |
| `compute` | ECS Fargate, ALB, auto-scaling, ECR, health checks |
| `database` | RDS Postgres, private subnet, encryption, automated backups |
| `secrets` | AWS Secrets Manager, auto-injected into ECS at runtime |
| `dns` | Route 53, ACM certificate (HTTPS), A record → ALB |
| `storage` | S3 bucket, CloudFront CDN, lifecycle policies |
| `monitoring` | CloudWatch alarms, dashboards, SNS email alerts |

---

## Getting started

### Prerequisites
- Terraform >= 1.6
- AWS CLI configured (`aws configure`)
- A Route 53 hosted zone for your domain

### 1. Bootstrap remote state (once per project)
```bash
cd scripts
chmod +x bootstrap.sh
./bootstrap.sh <your-project-name> eu-west-1
```

### 2. Deploy dev
```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Fill in your values
terraform init
terraform plan
terraform apply
```

### 3. Promote to staging → prod
Same flow. Each environment has its own isolated state file.

---

## Environment comparison

| Setting | dev | staging | prod |
|---------|-----|---------|------|
| AZs | 2 | 2 | 3 |
| NAT Gateways | 1 (shared) | 2 (per AZ) | 3 (per AZ) |
| ECS tasks | 1 | 2 | 3 |
| Task size | 0.25 vCPU / 512MB | 0.5 vCPU / 1GB | 1 vCPU / 2GB |
| RDS instance | t3.micro | t3.small | t3.medium |
| RDS Multi-AZ | No | No | Yes |
| Deletion protection | No | No | Yes |
| Log retention | 7 days | 14 days | 30 days |
| Fargate type | SPOT | SPOT | ON-DEMAND |

---

## Cost estimate

### Dev (~$85/month)
| Resource | Cost |
|----------|------|
| ECS Fargate (1 task, SPOT) | ~$5 |
| RDS t3.micro | ~$15 |
| NAT Gateway (1) | ~$35 |
| ALB | ~$20 |
| S3 + CloudFront | ~$2 |
| Secrets Manager | ~$1 |
| **Total** | **~$78/month** |

### Prod (~$350/month)
| Resource | Cost |
|----------|------|
| ECS Fargate (3 tasks, ON-DEMAND) | ~$60 |
| RDS t3.medium Multi-AZ | ~$100 |
| NAT Gateways (3) | ~$105 |
| ALB | ~$20 |
| S3 + CloudFront | ~$10 |
| Route 53 | ~$5 |
| **Total** | **~$300/month** |

> Use [infracost.io](https://infracost.io) to get exact estimates before applying.

---

## Security principles baked in

- **No public subnets for databases or apps** — only the ALB is public
- **IAM least privilege** — every role scoped to exactly what it needs
- **OIDC for CI/CD** — zero long-lived AWS keys stored anywhere
- **Secrets Manager** — never in env vars, tfvars, or Docker images
- **Encryption at rest** — RDS, S3, CloudWatch logs
- **VPC Flow Logs** — enabled by default
- **ECR image scanning** — on every push
- **Auto-rollback** — ECS rolls back failed deployments automatically
- **Deletion protection** — enabled on prod RDS and ALB

---

## Repo structure

```
terraform-starter-kit/
├── modules/
│   ├── networking/     main.tf · variables.tf · outputs.tf
│   ├── iam/            main.tf · variables.tf · outputs.tf
│   ├── compute/        main.tf · variables.tf · outputs.tf
│   ├── database/       main.tf · variables.tf · outputs.tf
│   ├── secrets/        main.tf · variables.tf · outputs.tf
│   ├── dns/            main.tf · variables.tf · outputs.tf
│   ├── storage/        main.tf · variables.tf · outputs.tf
│   └── monitoring/     main.tf · variables.tf · outputs.tf
├── environments/
│   ├── dev/            main.tf · variables.tf · outputs.tf · terraform.tfvars.example
│   ├── staging/        main.tf · variables.tf · outputs.tf · terraform.tfvars.example
│   └── prod/           main.tf · variables.tf · outputs.tf · terraform.tfvars.example
├── scripts/
│   └── bootstrap.sh
├── .github/
│   └── workflows/
│       └── deploy.yml
├── .gitignore
└── README.md
```

---

*Star the repo if this saved you time. Built from real pain at Phacet.*

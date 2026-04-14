#!/bin/bash
# Bootstrap remote Terraform state (run once per project)
# Usage: ./bootstrap.sh <project-name> <aws-region>

set -euo pipefail

PROJECT=${1:?Usage: ./bootstrap.sh <project-name> <aws-region>}
REGION=${2:?Usage: ./bootstrap.sh <project-name> <aws-region>}
BUCKET="${PROJECT}-terraform-state"
TABLE="${PROJECT}-terraform-locks"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🚀 Bootstrapping Terraform state for project: $PROJECT"
echo "   Region:  $REGION"
echo "   Account: $ACCOUNT_ID"
echo ""

# S3 bucket
echo "→ Creating S3 state bucket..."
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || echo "  (bucket already exists)"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "  ✓ S3 bucket ready: $BUCKET"

# DynamoDB lock table
echo "→ Creating DynamoDB lock table..."
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" 2>/dev/null || echo "  (table already exists)"

echo "  ✓ DynamoDB table ready: $TABLE"

echo ""
echo "✅ Done. Update environments/*/main.tf backend block with:"
echo "   bucket         = \"$BUCKET\""
echo "   dynamodb_table = \"$TABLE\""
echo "   region         = \"$REGION\""

#!/bin/bash

# Infrastructure Automation Project Cleanup Script
# This script helps to tear down the project infrastructure

set -e

echo "🧹 AWS Infrastructure Automation Project Cleanup"
echo "==============================================="

# Check required tools
echo "🔍 Checking for required tools..."

command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is not installed. Please install it first."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is not installed. Please install it first."; exit 1; }

echo "✅ Required tools are installed."

# Confirm before proceeding
echo "⚠️  WARNING: This script will destroy ALL resources created by this project."
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "🛑 Cleanup cancelled."
    exit 0
fi

# Set project variables
PROJECT_NAME="aws-iac-project"
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    echo "⚠️  AWS region not set in config, using default: $AWS_REGION"
fi

# Destroy Terraform infrastructure
echo "🔍 Destroying infrastructure with Terraform..."
cd ../terraform
terraform init
terraform destroy -auto-approve

# Delete SSH key from AWS
KEY_NAME="${PROJECT_NAME}-key"
echo "🔑 Deleting SSH key from AWS: $KEY_NAME"
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$AWS_REGION" 2>&1 >/dev/null; then
    aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$AWS_REGION"
    echo "✅ SSH key deleted from AWS."
else
    echo "ℹ️ SSH key not found in AWS."
fi

# Get S3 bucket and DynamoDB table names
BUCKET_NAME="${PROJECT_NAME}-terraform-state-$(aws sts get-caller-identity --query Account --output text)"
DYNAMODB_TABLE="${PROJECT_NAME}-terraform-locks"

# Ask if user wants to delete the S3 bucket and DynamoDB table
echo
echo "⚠️  Do you want to delete the Terraform state S3 bucket and DynamoDB lock table?"
echo "    This will permanently delete all Terraform state history."
read -p "Delete state storage? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Empty and delete S3 bucket
    echo "🗑️ Emptying and deleting S3 bucket: $BUCKET_NAME"
    if aws s3 ls "s3://$BUCKET_NAME" 2>&1 >/dev/null; then
        aws s3 rm "s3://$BUCKET_NAME" --recursive
        aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
        echo "✅ S3 bucket emptied and deleted."
    else
        echo "ℹ️ S3 bucket not found."
    fi

    # Delete DynamoDB table
    echo "🗑️ Deleting DynamoDB table: $DYNAMODB_TABLE"
    if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" 2>&1 >/dev/null; then
        aws dynamodb delete-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION"
        echo "✅ DynamoDB table deleted."
    else
        echo "ℹ️ DynamoDB table not found."
    fi
else
    echo "ℹ️ Keeping Terraform state storage for future use."
fi

# Clean up local files
echo "🧹 Cleaning up local files..."
rm -f ../terraform/backend.tf
rm -f ../terraform/terraform.tfvars
rm -f ../terraform/.terraform.lock.hcl
rm -rf ../terraform/.terraform
rm -f ../terraform/*.tfstate*
echo "✅ Local files cleaned up."

echo "🚀 Cleanup complete! All project resources have been removed."
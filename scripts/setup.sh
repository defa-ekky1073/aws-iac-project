#!/bin/bash

# Infrastructure Automation Project Setup Script
# This script helps to set up the project environment

set -e

echo "📋 AWS Infrastructure Automation Project Setup"
echo "=============================================="

# Check required tools
echo "🔍 Checking for required tools..."

command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is not installed. Please install it first."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is not installed. Please install it first."; exit 1; }
command -v ansible >/dev/null 2>&1 || { echo "❌ Ansible is not installed. Please install it first."; exit 1; }

echo "✅ Required tools are installed."

# Configure AWS CLI if not already configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "🔧 AWS CLI not configured. Setting it up now..."
    aws configure
else
    echo "✅ AWS CLI already configured."
fi

# Set project variables
echo "🔧 Setting up project variables..."
PROJECT_NAME="aws-iac-project"
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    echo "⚠️  AWS region not set in config, using default: $AWS_REGION"
fi

# Create S3 bucket for Terraform state if it doesn't exist
BUCKET_NAME="${PROJECT_NAME}-terraform-state-$(aws sts get-caller-identity --query Account --output text)"
echo "🔧 Creating S3 bucket for Terraform remote state: $BUCKET_NAME"

if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 >/dev/null; then
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
        
    # Enable versioning on the bucket
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
        
    # Enable encryption on the bucket
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
    echo "✅ S3 bucket created successfully."
else
    echo "✅ S3 bucket already exists."
fi

# Create DynamoDB table for state locking
DYNAMODB_TABLE="${PROJECT_NAME}-terraform-locks"
echo "🔧 Creating DynamoDB table for state locking: $DYNAMODB_TABLE"

if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" 2>&1 >/dev/null; then
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$AWS_REGION"
    echo "✅ DynamoDB table created successfully."
else
    echo "✅ DynamoDB table already exists."
fi

# Create backend.tf configuration file
echo "🔧 Creating Terraform backend configuration..."
cat > ../terraform/backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "terraform.tfstate"
    region         = "${AWS_REGION}"
    dynamodb_table = "${DYNAMODB_TABLE}"
    encrypt        = true
  }
}
EOF
echo "✅ Terraform backend configuration created."

# Generate SSH key for EC2 instances if it doesn't exist
KEY_NAME="${PROJECT_NAME}-key"
KEY_PATH="../terraform/${KEY_NAME}.pem"

if [ ! -f "$KEY_PATH" ]; then
    echo "🔑 Generating SSH key for EC2 instances: $KEY_NAME"
    ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
    chmod 400 "$KEY_PATH"
    
    # Import key to AWS if needed
    if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$AWS_REGION" 2>&1 >/dev/null; then
        aws ec2 import-key-pair \
            --key-name "$KEY_NAME" \
            --public-key-material fileb://"${KEY_PATH}.pub" \
            --region "$AWS_REGION"
    fi
    echo "✅ SSH key generated and imported to AWS."
else
    echo "✅ SSH key already exists."
fi

echo "🔧 Creating local terraform.tfvars file..."
cat > ../terraform/terraform.tfvars << EOF
aws_region = "${AWS_REGION}"
project = "${PROJECT_NAME}"
key_name = "${KEY_NAME}"
ssh_key_path = "${KEY_PATH}"
EOF
echo "✅ terraform.tfvars file created."

echo "🚀 Project setup complete! You can now use Terraform and Ansible to deploy your infrastructure."
echo "📝 Next steps:"
echo "  1. Review the terraform.tfvars file and update any settings as needed"
echo "  2. Run 'cd ../terraform && terraform init' to initialize Terraform"
echo "  3. Run 'terraform plan' to see what will be created"
echo "  4. Run 'terraform apply' to create the infrastructure"
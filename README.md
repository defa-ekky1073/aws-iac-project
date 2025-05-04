# AWS Infrastructure Automation Project

## 🎯 Project Goal
End-to-End Infrastructure Automation with Terraform & Ansible on AWS to:
- Provision and manage AWS infrastructure using Terraform
- Configure and deploy software with Ansible
- Set up CI/CD pipelines using GitHub Actions
- Implement observability using Grafana and Prometheus

## 📊 Architecture
```
Developer → GitHub Actions → Terraform → AWS EC2
                             ↘︎ Ansible → Provision & Deploy (NGINX, App, Monitoring)
                                                             ↘︎ Prometheus + Grafana
```

## 📂 Project Structure
- **terraform/** - Contains Terraform configurations for AWS resources
  - **modules/** - Reusable Terraform modules
    - **vpc/** - VPC configuration
    - **ec2/** - EC2 instance configuration
    - **security/** - Security groups and IAM configurations
- **ansible/** - Contains Ansible playbooks and roles
  - **roles/** - Reusable Ansible roles for various components
  - **playbooks/** - Ansible playbooks for configuration management
- **.github/workflows/** - CI/CD pipeline configurations
- **monitoring/** - Monitoring configurations and documentation
  - **prometheus/** - Prometheus configuration
  - **grafana/** - Grafana dashboards and configuration
- **scripts/** - Helper scripts for the project

## 🚀 Getting Started

### Prerequisites
1. Install required tools:
   - [AWS CLI](https://aws.amazon.com/cli/)
   - [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
   - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (v2.9+)

2. AWS account with appropriate permissions

### Setup Process

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd aws-iac-project
   ```

2. Run the setup script:
   ```bash
   ./scripts/setup.sh
   ```
   This script will:
   - Verify required tools are installed
   - Configure AWS credentials if needed
   - Create an S3 bucket and DynamoDB table for Terraform state
   - Generate SSH keys for EC2 instances
   - Create necessary configuration files

3. Deploy the infrastructure:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

4. Wait for the deployment to complete. The outputs will show:
   - EC2 instance public IP
   - URLs for application and monitoring tools

### Manual Deployment (Alternative to CI/CD)

If you prefer to deploy manually instead of using GitHub Actions:

1. Provision infrastructure with Terraform:
   ```bash
   cd terraform
   terraform apply -auto-approve
   ```

2. Configure the servers with Ansible:
   ```bash
   cd ../ansible
   ansible-playbook playbooks/main.yml
   ```

## 📊 Monitoring

After deployment, you can access:

1. **Grafana dashboard**: http://[EC2_PUBLIC_IP]:3000
   - Default login: admin/admin
   - Pre-configured dashboards for system metrics

2. **Prometheus**: http://[EC2_PUBLIC_IP]:9090
   - Metrics collection and query interface

For more details on monitoring, refer to [monitoring/README.md](monitoring/README.md).

## 🔄 CI/CD Pipeline

The CI/CD pipeline is configured in `.github/workflows/deploy.yml` and includes:

1. **Terraform Workflow**:
   - Checkout code
   - Initialize Terraform
   - Validate and plan infrastructure changes
   - Apply changes (on push to main)

2. **Ansible Workflow**:
   - Configure newly provisioned infrastructure
   - Deploy the application and monitoring stack

## 🧹 Cleanup

To clean up all resources:

```bash
./scripts/cleanup.sh
```

This script will:
1. Destroy all AWS resources created by Terraform
2. Delete the SSH key from AWS
3. Optionally remove the S3 bucket and DynamoDB table for Terraform state
4. Clean up local configuration files

## 📘 Additional Documentation

- [Infrastructure Design](docs/infrastructure.md)
- [Monitoring Documentation](monitoring/README.md)
- [Ansible Roles](docs/ansible-roles.md)

## 🔐 Security Considerations

- Use AWS IAM roles with least privilege
- Restrict security group access to necessary ports only
- Rotate SSH keys regularly
- Keep all components updated with security patches
- Store sensitive data in AWS Secrets Manager or Parameter Store
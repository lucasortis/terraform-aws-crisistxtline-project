# Crisis Text Line - Terraform Infrastructure

*This README was created using Claude Sonnet 4 through GitHub Copilot and fully revised by me.*

This repository contains the Terraform infrastructure code for the Crisis Text Line project, designed with multi-environment support and modular architecture.

## Quick Start

1. **Clone the repository**
2. **Configure your AWS credentials** (AWS CLI profile)
3. **Create/configure S3 backend (if needed)** (see [Backend Setup](#backend-setup))
4. **Run Terraform commands** using the helper script

```bash
# Plan for dev environment
./terraform-helper.sh --env=dev plan

# Apply for dev environment  
./terraform-helper.sh --env=dev apply

# Destroy resources
./terraform-helper.sh --env=dev destroy
```

## Architecture

The infrastructure is organized into reusable modules:

- **VPC Module** (`modules/vpc/`) - Complete VPC setup with public/private subnets
- **Security Group Module** (`modules/security-group/`) - Network security and access control
- **ALB Module** (`modules/alb/`) - Application Load Balancer for traffic distribution
- **ECS Module** (`modules/ecs/`) - Containerized application hosting with Fargate
- **IAM Module** (`modules/iam/`) - Secure access management and roles
- **CloudWatch Module** (`modules/cloudwatch/`) - Monitoring, logging, and alerting

## Environment Management

### Current Environments

The project supports multiple environments with isolated state and configurations:

- **dev** - Development environment
- **prd** - Production environment

### Environment Structure

Each environment has its own directory under `environments/`:

```
environments/
├── dev/
│   ├── terraform.tfvars      # Environment-specific variables
│   └── terraform.s3.tfbackend # S3 backend configuration
└── prd/
    ├── terraform.tfvars
    └── terraform.s3.tfbackend
```

### Adding New Environments

To add a new environment (e.g., `stg`, `uat`, `qa`):

1. **Update variable validation** in `variables.tf`:
   ```hcl
   variable "environment" {
     description = "The environment for which the resources are being created."
     type        = string
     validation {
       condition     = contains(["dev", "stg", "uat", "qa", "prd"], var.environment)
       error_message = "The environment must be one of: dev, stg, uat, qa, prd."
     }
   }
   ```

2. **Create environment directory**:
   ```bash
   mkdir environments/stg
   ```

3. **Create `terraform.tfvars`**:
   ```hcl
   region      = "us-east-1"
   profile     = "personal"
   environment = "stg"
   
   tags = {
     "Environment" = "stg"
     "Project"     = "Crisis Text Line"
     "CostCenter"  = "Engineering Team"
   }
   
   project_name = "CrisisTextLine"
   create_vpc   = true
   cidr_block   = "10.43.0.0/16"  # Use different CIDR per environment
   ```

4. **Create `terraform.s3.tfbackend`**:
   ```hcl
   bucket       = "your-bucket-name-stg"
   key          = "crisistextline-project/terraform.tfstate"
   region       = "us-east-1"
   profile      = "personal"
   use_lockfile = true
   ```

## Terraform Helper Script

The `terraform-helper.sh` script simplifies Terraform operations across environments.

### Usage

```bash
./terraform-helper.sh [-e=ENVIRONMENT|--env=ENVIRONMENT] [COMMAND]
```

### Parameters

- **Environment Flag**: `-e=ENV` or `--env=ENV`
  - Default: `dev`
  - Available: `dev`, `prd` (or custom environments you create)

- **Commands**:
  - `plan` - Creates execution plan and saves to `tfplan`
  - `apply` - Applies the saved plan from `tfplan`
  - `destroy` - Destroys all managed infrastructure

### Examples

```bash
# Development environment
./terraform-helper.sh -e=dev plan
./terraform-helper.sh -e=dev apply

# Production environment
./terraform-helper.sh --env=prd plan
./terraform-helper.sh --env=prd apply

# Default environment (dev)
./terraform-helper.sh plan
./terraform-helper.sh apply

# Cleanup
./terraform-helper.sh -e=dev destroy
```

### How It Works

The script:
1. Cleans up any existing `.terraform` directory
2. Validates the specified environment exists
3. Runs `terraform init` with the environment-specific backend configuration
4. Executes the requested Terraform command with environment-specific variables

## Backend Setup

This project uses S3 for remote state storage. Each environment has its own S3 bucket for isolation.

### Creating S3 Backend Buckets

To create S3 buckets for Terraform state storage, use the dedicated repository:

**Repository**: https://github.com/lucasortis/terraform-aws-s3-tfstate

1. Clone the S3 backend repository
2. Follow the setup instructions in its README
3. Create buckets for each environment
4. Update the `terraform.s3.tfbackend` files with your bucket names

### Backend Configuration

Each environment's `terraform.s3.tfbackend` file should contain:

```hcl
bucket       = "your-unique-bucket-name-{env}"
key          = "crisistextline-project/terraform.tfstate"
region       = "us-east-1"
profile      = "personal"
use_lockfile = true
```

## Project Structure

```
.
├── main.tf                    # Root module configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider requirements
├── terraform-helper.sh        # Environment management script
├── .terraform.lock.hcl        # Provider version locks
├── .pre-commit-config.yaml    # Code quality hooks
├── .gitignore                 # Git ignore rules
├── environments/              # Environment-specific configurations
│   ├── dev/
│   └── prd/
└── modules/                   # Reusable Terraform modules
    ├── vpc/                   # VPC infrastructure
    ├── security-group/        # Security group rules
    ├── alb/                   # Application Load Balancer
    ├── ecs/                   # Container orchestration
    ├── iam/                   # IAM roles and policies
    └── cloudwatch/            # Monitoring and logging
```

## Requirements

- **Terraform**: >= 1.12
- **AWS Provider**: ~> 6.0
- **AWS CLI**: Configured with appropriate profiles
- **Bash**: For the helper script

## Code Quality

The project includes pre-commit hooks for:
- Terraform formatting (`terraform fmt`)
- Terraform validation (`terraform validate`)

Install and configure:
```bash
pip install pre-commit
pre-commit install
```

## TODO - Assignment Requirements

The following modules need to be implemented to complete the secure, highly available, and scalable web application infrastructure:

### 🔒 Security Group Module (`modules/security-group/`)
Required for secure network isolation
- [ ] ALB security group (HTTP/HTTPS from internet: 0.0.0.0/0:80,443)
- [ ] ECS service security group (HTTP from ALB only: ALB-SG:8000)
- [ ] NAT Gateway security group (HTTPS outbound for ECS tasks)
- [ ] Implement least privilege access principles
- [ ] Document security group rules and their purposes

### 🐳 ECS Module (`modules/ecs/`)
Core application hosting
- [ ] ECS Cluster with Fargate launch type
- [ ] Task Definition for `crccheck/hello-world` Docker image
  - [ ] Container port 8000 exposed
  - [ ] Resource limits (CPU: 256, Memory: 512)
  - [ ] CloudWatch Logs configuration
- [ ] ECS Service with minimum 2 tasks across multiple AZs
- [ ] Service auto-scaling configuration (target tracking)
- [ ] Integration with Application Load Balancer target group
- [ ] Health check configuration

### 🏗️ Load Balancer Module (`modules/alb/`)
Traffic routing and high availability
- [ ] Application Load Balancer in public subnets
- [ ] Target Group for ECS service (port 8000, health check path `/`)
- [ ] ALB Listener (HTTP:80 → Target Group)
- [ ] Access logging to S3 bucket (encrypted)
- [ ] Security group integration

### 📊 CloudWatch Module (`modules/cloudwatch/`)
Monitoring and alerting
- [ ] Log Groups for ECS tasks with retention policy
- [ ] CloudWatch Dashboard for ECS and ALB metrics
- [ ] CloudWatch Alarms:
  - [ ] ECS service unhealthy tasks
  - [ ] ALB target health
  - [ ] High CPU/Memory utilization
- [ ] SNS topic for alarm notifications
- [ ] Metric filters for application logs

### 🔐 IAM Module (`modules/iam/`)
Secure access management
- [ ] ECS Task Execution Role (ECR, CloudWatch Logs access)
- [ ] ECS Task Role (minimal permissions for application)
- [ ] CloudWatch Logs permissions
- [ ] S3 access policies for log storage

### 🔧 Additional Infrastructure Components
Nice to have features
- [ ] Route 53 DNS configuration
- [ ] SSL/TLS certificate via ACM
- [ ] WAF integration for additional security
- [ ] VPC Flow Logs for network monitoring
- [ ] Systems Manager Parameter Store for configuration


## Technical Specifications

### Docker Application Details
- **Image**: `crccheck/hello-world`
- **Container Port**: 8000
- **Health Check**: HTTP GET `/` (expects 200 OK)
- **Resource Requirements**: Minimal (256 CPU, 512 MB memory)


### Testing Command
```bash
# After deployment, test the ALB endpoint
curl -I http://<alb-dns-name>
# Expected: HTTP/1.0 200 OK
```

## Support

For questions about the S3 backend setup, refer to: https://github.com/lucasortis/terraform-aws-s3-tfstate

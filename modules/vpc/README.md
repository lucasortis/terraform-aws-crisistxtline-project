# VPC Module
*This README was created using Claude Sonnet 4 through GitHub Copilot and revised by me.*

This Terraform module creates a fully configured AWS VPC with public and private subnets across two availability zones, including NAT gateways for secure outbound internet access from private subnets.

## Architecture

The module creates the following resources:

- **VPC** with DNS support and hostnames enabled
- **Public Subnets** (2) - one in each AZ with public IP assignment
- **Private Subnets** (2) - one in each AZ for secure workloads
- **Internet Gateway** for public internet access
- **NAT Gateways** (2) - one per AZ for high availability
- **Route Tables** - separate for public and private subnets
- **Elastic IPs** for NAT gateways

## Network Design

- **CIDR Allocation**: Uses `cidrsubnet()` function to automatically calculate subnet CIDRs
  - Public Subnet 1A: `cidrsubnet(var.cidr_block, 8, 1)`
  - Public Subnet 1B: `cidrsubnet(var.cidr_block, 8, 2)`
  - Private Subnet 1A: `cidrsubnet(var.cidr_block, 8, 3)`
  - Private Subnet 1B: `cidrsubnet(var.cidr_block, 8, 4)`

- **High Availability**: Resources are distributed across two availability zones (a and b)
- **Security**: Private subnets route through NAT gateways for outbound internet access

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  environment  = "dev"
  project_name = "MyProject"
  cidr_block   = "10.0.0.0/16"
  create_vpc   = true
  
  tags = {
    Environment = "dev"
    Project     = "MyProject"
    CostCenter  = "Engineering"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Environment name (dev or prd) | `string` | n/a | yes |
| `project_name` | Project name for resource naming | `string` | n/a | yes |
| `cidr_block` | VPC CIDR block | `string` | n/a | yes |
| `tags` | Additional tags for resources | `map(any)` | n/a | yes |
| `create_vpc` | Whether to create VPC | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `vpc_arn` | The ARN of the VPC |
| `public_subnet_1a` | Public subnet ID for AZ 1a |
| `public_subnet_1b` | Public subnet ID for AZ 1b |
| `private_subnet_1a` | Private subnet ID for AZ 1a |
| `private_subnet_1b` | Private subnet ID for AZ 1b |

## Resource Naming Convention

Resources follow a consistent naming pattern: `{type}-{optional-az}-{project_name}-{environment}`

Examples:
- VPC: `vpc-MyProject-dev`
- Public Subnet: `pub-subnet-1a-MyProject-dev`
- Private Subnet: `priv-subnet-1a-MyProject-dev`
- NAT Gateway: `ngw-1a-MyProject-dev`
- Public Route Table: `pub-route-table-MyProject-dev`
- Private Route table AZ A: `priv-route-table-1a-MyProject-dev`
- Private Route table AZ B: `priv-route-table-1b-MyProject-dev`
<img width="1549" height="550" alt="image" src="https://github.com/user-attachments/assets/391a4a4d-8e15-4b37-899c-2bf4f31f180a" />
<img width="2080" height="359" alt="image" src="https://github.com/user-attachments/assets/01b850fc-d76e-42b6-9709-3e21ac68a458" />


## Requirements

- Terraform >= 1.12
- AWS Provider ~> 6.0
- Valid AWS credentials configured

## Cost Considerations

**NAT Gateways** are the most expensive components in this module:
- Each NAT Gateway costs ~$45/month + data processing charges
- This module creates 2 NAT Gateways for high availability
- Consider using a single NAT Gateway in non-production environments to reduce costs

## Notes

- The module automatically detects the current AWS region using `data.aws_region.current`
- All resources are conditionally created based on the `create_vpc` variable
- Tags are merged with resource-specific tags for consistent tagging
- DNS support and hostnames are enabled by default for the VPC

#

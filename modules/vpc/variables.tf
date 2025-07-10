variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, prd)."
  type        = string
  validation {
    condition     = var.environment == "dev" || var.environment == "prd"
    error_message = "The environment must be either 'dev' or 'prd'."
  }
}

variable "create_vpc" {
  description = "Flag to create the VPC. Set to false if the VPC already exists."
  type        = bool
  default     = true
}

variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (Name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

variable "cidr_block" {
  type        = string
  description = "Networking CIDR block to be used for the VPC"
}

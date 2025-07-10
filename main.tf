module "ecs_network" {
  source       = "./modules/vpc"
  environment  = var.environment
  create_vpc   = var.create_vpc
  project_name = var.project_name
  cidr_block   = var.cidr_block
  tags         = var.tags
}

locals {
  name       = "${var.project_name}-${var.environment}"
  create_vpc = var.create_vpc
}

resource "aws_vpc" "this" {
  count                = local.create_vpc ? 1 : 0
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
      Name        = "vpc-${local.name}",
      Environment = var.environment,
    }
  )
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone       = "${data.aws_region.current.region}a"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "pub-subnet-1a-${local.name}",
    }
  )
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone       = "${data.aws_region.current.region}b"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "pub-subnet-1b-${local.name}",
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "pub-route-table-${local.name}"
    }
  )
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}


################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      Name = "igw-${local.name}"
    }
  )
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3)
  availability_zone = "${data.aws_region.current.region}a"

  tags = merge(
    var.tags,
    {
      Name = "priv-subnet-1a-${local.name}",
    }
  )
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 4)
  availability_zone = "${data.aws_region.current.region}b"

  tags = merge(
    var.tags,
    {
      Name = "priv-subnet-1b-${local.name}",
    }
  )
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_1b.id
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat_1a" {
  domain = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "eip-1a-${local.name}"
    }
  )
}

resource "aws_eip" "nat_1b" {
  domain = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "eip-1b-${local.name}"
    }
  )
}

resource "aws_nat_gateway" "ngw_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = merge(
    var.tags,
    {
      Name = "ngw-1a-${local.name}"
    }
  )
}

resource "aws_nat_gateway" "ngw_1b" {
  allocation_id = aws_eip.nat_1b.id
  subnet_id     = aws_subnet.public_1b.id

  tags = merge(
    var.tags,
    {
      Name = "ngw-1b-${local.name}"
    }
  )
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1a.id
  }

  tags = merge(
    var.tags,
    {
      Name = "priv-route-table-1a-${local.name}"
    }
  )
}

resource "aws_route_table" "private_1b" {
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1b.id
  }

  tags = merge(
    var.tags,
    {
      Name = "priv-route-table-1b-${local.name}"
    }
  )
}


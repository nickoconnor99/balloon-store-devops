terraform {
  backend "s3" {
    bucket  = "nickoconnor-tfstate-2026"
    key     = "balloon-store/terraform.tfstate"
    region  = "us-east-1"
    profile = "devops-admin"
  }
}


terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "devops-admin"

}

resource "aws_vpc" "balloon_store" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "balloon-store-vpc"
    Environment = "dev"
    Project     = "balloon-store"
  }
}


# Public subnet - Availability Zone A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.balloon_store.id
  cidr_block              = "10.0.32.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "balloon-store-public-a"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Public subnet - Availability Zone B
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.balloon_store.id
  cidr_block              = "10.0.33.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "balloon-store-public-b"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Private subnet - Availability Zone A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.balloon_store.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "balloon-store-private-a"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Private subnet - Availability Zone B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.balloon_store.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "balloon-store-private-b"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "balloon_store" {
  vpc_id = aws_vpc.balloon_store.id

  tags = {
    Name        = "balloon-store-igw"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.balloon_store.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.balloon_store.id
  }

  tags = {
    Name        = "balloon-store-public-rt"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Associate Public Subnet A with Public Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Associate Public Subnet B with Public Route Table
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.balloon_store.id

  tags = {
    Name        = "balloon-store-private-rt"
    Environment = "dev"
    Project     = "balloon-store"
  }
}

# Private Subnet Route Table Associations
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
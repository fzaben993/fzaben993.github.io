
data "aws_availability_zone" "az1" {
  name = "eu-west-1a"
}

data "aws_availability_zone" "az2" {
  name = "eu-west-1b"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-west-1"
}

# Define variables
variable "environment_name" {
  description = "An environment name that will be prefixed to resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "Please enter the IP range (CIDR notation) for this VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the second Availability Zone"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the second Availability Zone"
  type        = string
  default     = "10.0.3.0/24"
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.environment_name
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.environment_name
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = data.aws_availability_zone.az1.name
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment_name} Public Subnet (AZ1)"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = data.aws_availability_zone.az2.name
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment_name} Public Subnet (AZ2)"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = data.aws_availability_zone.az1.name
  tags = {
    Name = "${var.environment_name} Private Subnet (AZ1)"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = data.aws_availability_zone.az2.name
  tags = {
    Name = "${var.environment_name} Private Subnet (AZ2)"
  }
}

# Create NAT Gateways
resource "aws_eip" "nat_gateway1_eip" {
  vpc = true
}

resource "aws_eip" "nat_gateway2_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_gateway1_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_gateway2_eip.id
  subnet_id     = aws_subnet.public_subnet2.id
}

# Create Route Tables and Routes
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment_name} Public Routes"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_subnet1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment_name} Private Routes (AZ1)"
  }
}

resource "aws_route" "default_private_route1" {
  route_table_id         = aws_route_table.private_route_table1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway1.id
}

resource "aws_route_table_association" "private_subnet1_route_table_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment_name} Private Routes (AZ2)"
  }
}

resource "aws_route" "default_private_route2" {
  route_table_id         = aws_route_table.private_route_table2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway2.id
}

# Outputs
output "vpc_id" {
  description = "A reference to the created VPC"
  value       = aws_vpc.vpc.id
}

output "public_route_table_id" {
  description = "Public Routing"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table1_id" {
  description = "Private Routing AZ1"
  value       = aws_route_table.private_route_table1.id
}

output "private_route_table2_id" {
  description = "Private Routing AZ2"
  value       = aws_route_table.private_route_table2.id
}

output "public_subnets" {
  description = "A list of the public subnets"
  value       = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

output "private_subnets" {
  description = "A list of the private subnets"
  value       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

output "public_subnet1_id" {
  description = "A reference to the public subnet in the 1st Availability Zone"
  value       = aws_subnet.public_subnet1.id
}

output "public_subnet2_id" {
  description = "A reference to the public subnet in the 2nd Availability Zone"
  value       = aws_subnet.public_subnet2.id
}

output "private_subnet1_id" {
  description = "A reference to the private subnet in the 1st Availability Zone"
  value       = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
  description = "A reference to the private subnet in the 2nd Availability Zone"
  value       = aws_subnet.private_subnet2.id
}

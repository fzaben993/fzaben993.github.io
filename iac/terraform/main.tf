
data "aws_availability_zone" "az1" {
  name = "eu-west-1a"
}

data "aws_availability_zone" "az2" {
  name = "eu-west-1b"
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

variable "AmazonLinuxAMI" {
  description = "Enter the Amazon Linux AMI for the region in which you are deploying this stack"
}

variable "KeyPairName" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances"
}

variable "InstanceType" {
  description = "Enter the instance type for the web servers"
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
  shared_credentials_files = ["~/.aws/credentials"]
}
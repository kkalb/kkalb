variable "ecr_repository" {
  description = "The ECR repository name"
  type        = string
  default     = "kkalb"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "192247731055"
}

variable "environment" {
  description = "The project environment"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR for the VPC"
}

variable "vpc_public_subnets" {
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "Public subnets for the VPC"
}

variable "vpc_private_subnets" {
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Private subnets for the VPC"
}

variable "vpc_availability_zones" {
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "Availability zones for subnets"
}

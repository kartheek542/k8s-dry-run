variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance. If not provided, the latest Ubuntu 22.04 LTS AMI will be used."
  type        = string
  default     = "ami-01a00762f46d584a1" #Ubuntu: 26.04
  # default     = "ami-006f82a1d5a27da54" #Ubuntu: 24.04
}
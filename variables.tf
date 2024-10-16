# variables.tf
variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}
variable "vpc_az" {
  type = list(string)
  description = "VPC AZ"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}
variable "ami" {
  description = "EC2 instance AMI"
  default     = "ami-0ad522a4a529e7aa8"
}
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  default     = 2
}



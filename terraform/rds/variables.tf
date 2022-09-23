variable "vpc_id" {
  description = "ID of the VPC in which security resources are deployed"
  type = string
}

variable "sns_arn" {
  description = "ARN of SNS to send cloudwatch logs to"
  type = string
}

variable "database_subnet_group_name" {
  description = "Group name for database subnet."
  type = string
}
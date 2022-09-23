module "sns_topic" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name  = "wyze"
}

output "arn" {
  value = module.sns_topic.sns_topic_arn 
}
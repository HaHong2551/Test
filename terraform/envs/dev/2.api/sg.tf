# module "sg_general" {
#   source = "git@github.com:framgia/sun-infra-iac.git//modules/security-group?ref=terraform-aws-security-group_v0.0.1"
#   #basic
#   env     = var.env
#   project = var.project

#   #sg
#   name   = "sg-2"
#   vpc_id = "vpc-00bcb5811b0b7aca7"
#   ingress_rules = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Test"
#     },
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "ssh"
#     }
#   ]
# }

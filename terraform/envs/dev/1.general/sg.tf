module "sg_general" {
  source = "git@github.com:framgia/sun-infra-iac-release.git//modules/security-group?ref=terraform-aws-security-group_v0.0.1"
  #basic
  env     = var.env
  project = var.project

  #sg
  name   = "sg-1"
  vpc_id = "vpc-00bcb5811b0b7aca7"
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Test"
    }
  ]
}

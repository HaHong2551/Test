# module "sg_general" {
#   source = "git@github.com:framgia/sun-infra-iac.git//modules/security-group?ref=terraform-aws-security-group_v0.0.1"
#   #basic
#   env     = var.env
#   project = var.project

#   #sg
#   name   = "sg-1"
#   vpc_id = "vpc-00bcb5811b0b7aca7"
#   ingress_rules = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Test"
#     }
#   ]
# }

# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#   vpc_id      = aws_vpc.main.id

#   tags = {
#     Name = "allow_tls"
#   }
# }

# # resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
# #   security_group_id = aws_security_group.allow_tls.id
# #   cidr_ipv4         = aws_vpc.main.cidr_block
# #   from_port         = 443
# #   ip_protocol       = "tcp"
# #   to_port           = 443
# # }

# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv6         = aws_vpc.main.ipv6_cidr_block
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

resource "aws_vpc" "main" {
  cidr_block       = "10.50.0.0/16"
  instance_tenancy = "defaultss"

  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.50.1.0/24"

  tags = {
    Name = "Main"
  }
}
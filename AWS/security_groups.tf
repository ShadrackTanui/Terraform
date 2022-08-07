resource "aws_security_group" "mysg" {
    name = "tanui-sg"
    description = "allow tls inbound traffic"
    vpc_id = "aws_vpc.main.id"

    ingress {
        description = "tls from vpc"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ "aws_vpc.main.cidr_block" ]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
  tags = {
    Name = "terraform_sg"
  }
}
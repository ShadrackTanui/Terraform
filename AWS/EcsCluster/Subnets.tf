resource "aws_subnet" "privatesubnet" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "us-east-1a"
  cidr_block                      = "10.1.4.0/24"
  map_public_ip_on_launch         = false
  tags = {
    "Name" = "Private subnet 1"
  }
  vpc_id = aws_vpc.Eks-Vpc.id

  timeouts {}
}

resource "aws_subnet" "publicsubnet" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "us-east-1a"
  cidr_block                      = "10.1.1.0/24"
  map_public_ip_on_launch         = false
  tags = {
    "Name" = "Public subnet 1"
  }
  vpc_id = aws_vpc.Eks-Vpc.id

  timeouts {}
}

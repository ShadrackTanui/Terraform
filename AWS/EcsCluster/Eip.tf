resource "aws_eip" "Eks-Eip" {
  public_ipv4_pool = "amazon"
  tags             = {}
  vpc              = true
  timeouts {}

}
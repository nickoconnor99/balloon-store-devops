
resource "aws_security_group" "eks_nodes" {
  name        = "balloon-store-eks-nodes"
  description = "Security group for Balloon Store EKS worker nodes"
  vpc_id      = aws_vpc.balloon_store.id

  tags = {
    Name = "balloon-store-eks-nodes"
  }
}


resource "aws_vpc_security_group_ingress_rule" "eks_nodes_internal" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_nodes.id

  ip_protocol = "-1"

  description = "Allow communication between EKS worker nodes"
}

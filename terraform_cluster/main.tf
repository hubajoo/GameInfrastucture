

data "aws_key_pair" "this" {
  key_pair_id        = "key-00af0d4664a425e86"
  include_public_key = true
}

resource "aws_eks_cluster" "this" {
  name = "huba-eks-tf-cluster"
  vpc_config {
    subnet_ids = [
      aws_subnet.public-a.id,
      #aws_subnet.private-a.id,
      aws_subnet.public-b.id,
      #aws_subnet.private-b.id,
    ]
  }
  role_arn = aws_iam_role.cluster.arn
}

resource "aws_iam_role" "cluster" {
  name = "uba-eks-tf-cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

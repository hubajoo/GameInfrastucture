resource "aws_vpc" "this" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "huba-tf-cluster-vpc"
  }

}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "huba-tf-cluster-gw"
  }
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "huba-tf-eip"
  }
}
//
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public"
  }
}
/*
resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.this.id

  
  tags = {
    Name = "acl_allow_tcp"
  }
}
resource "aws_network_acl_rule" "ssh-egress" {
 network_acl_id = aws_network_acl.this.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "ssh-ingress" {
 network_acl_id = aws_network_acl.this.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 22
  to_port        = 22
}


resource "aws_network_acl_rule" "http-egress" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "http-ingress" {
   network_acl_id = aws_network_acl.this.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 80
  to_port        = 80
}
*/
/*
resource "aws_subnet" "private-a" {

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "eu-central-1a"
  #map_public_ip_on_launch = true
  tags = {
    Name                              = "huba-tf-cluster-private-subnet-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/huba-eks-tf-cluster"      = "owned"
  }
}
resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private.id
}
*/
resource "aws_subnet" "public-a" {

  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.32.0/19"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "huba-tf-cluster-public-subnet-1a"
    "kubernetes.io/role/elb"                    = "1" #this instruct the kubernetes to create public load balancer in these subnets
    "kubernetes.io/cluster/huba-eks-tf-cluster" = "owned"
  }
}
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}
/*
resource "aws_subnet" "private-b" {

  vpc_id            = aws_vpc.this.id
  availability_zone = "eu-central-1b"
  cidr_block        = "10.0.64.0/19"
  #map_public_ip_on_launch = true

  tags = {
    Name                              = "huba-tf-cluster-private-subnet-1b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/huba-eks-tf-cluster"      = "owned"
  }
}
resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private.id
}
*/
resource "aws_subnet" "public-b" {

  vpc_id                  = aws_vpc.this.id
  availability_zone       = "eu-central-1b"
  cidr_block              = "10.0.96.0/19"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "huba-tf-cluster-public-subnet-1b"
    "kubernetes.io/role/elb"                    = "1" #this instruct the kubernetes to create public load balancer in these subnets
    "kubernetes.io/cluster/huba-eks-tf-cluster" = "owned"
  }
}
resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_traffic"
  description = "Allow inbound ssh, http, kubelet and kube-proxy traffic and all outbound traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "allow_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http.id

  #cidr_ipv4         = aws_vpc.this.cidr_block
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_http.id

  cidr_ipv4 = aws_vpc.this.cidr_block
  #cidr_ipv4         = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_kubelet_api" {
  security_group_id = aws_security_group.allow_http.id

  cidr_ipv4 = aws_vpc.this.cidr_block
  #cidr_ipv4         = "0.0.0.0/0"
  from_port   = 10250
  ip_protocol = "tcp"
  to_port     = 10250
}

resource "aws_vpc_security_group_ingress_rule" "allow_kube-proxy" {
  security_group_id = aws_security_group.allow_http.id

  cidr_ipv4 = aws_vpc.this.cidr_block
  #cidr_ipv4         = "0.0.0.0/0"
  from_port   = 10256
  ip_protocol = "tcp"
  to_port     = 10256
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_http.id

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


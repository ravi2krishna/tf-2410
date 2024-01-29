# VPC
resource "aws_vpc" "myntra-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myntra"
  }
}

# Web Subnet
resource "aws_subnet" "myntra-web-sn" {
  vpc_id     = aws_vpc.myntra-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "myntra-web-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "myntra-db-sn" {
  vpc_id     = aws_vpc.myntra-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "myntra-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "myntra-igw" {
  vpc_id = aws_vpc.myntra-vpc.id

  tags = {
    Name = "myntra-internet-gateway"
  }
}

# Web Route Table
resource "aws_route_table" "myntra-web-rt" {
  vpc_id = aws_vpc.myntra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myntra-igw.id
  }

  tags = {
    Name = "myntra-web-route-table"
  }
}

# Database Route Table
resource "aws_route_table" "myntra-database-rt" {
  vpc_id = aws_vpc.myntra-vpc.id

  tags = {
    Name = "myntra-database-route-table"
  }
}

# Web Subnet Association
resource "aws_route_table_association" "myntra-web-asc" {
  subnet_id      = aws_subnet.myntra-web-sn.id
  route_table_id = aws_route_table.myntra-web-rt.id
}

# Database Subnet Association
resource "aws_route_table_association" "myntra-database-asc" {
  subnet_id      = aws_subnet.myntra-db-sn.id
  route_table_id = aws_route_table.myntra-database-rt.id
}

# Web NACL
resource "aws_network_acl" "myntra-web-nacl" {
  vpc_id = aws_vpc.myntra-vpc.id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "myntra-web-nacl"
  }
}

# Database NACL
resource "aws_network_acl" "myntra-db-nacl" {
  vpc_id = aws_vpc.myntra-vpc.id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "myntra-db-nacl"
  }
}


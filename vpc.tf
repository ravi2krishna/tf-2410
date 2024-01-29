# VPC
resource "aws_vpc" "ibm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ibm"
  }
}

# Web Subnet
resource "aws_subnet" "ibm-web-sn" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ibm-web-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "ibm-db-sn" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ibm-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ibm-igw" {
  vpc_id = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm-internet-gateway"
  }
}

# Web Route Table
resource "aws_route_table" "ibm-web-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm-igw.id
  }

  tags = {
    Name = "ibm-web-route-table"
  }
}

# Database Route Table
resource "aws_route_table" "ibm-database-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm-database-route-table"
  }
}

# Web Subnet Association
resource "aws_route_table_association" "ibm-web-asc" {
  subnet_id      = aws_subnet.ibm-web-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}

# Database Subnet Association
resource "aws_route_table_association" "ibm-database-asc" {
  subnet_id      = aws_subnet.ibm-db-sn.id
  route_table_id = aws_route_table.ibm-database-rt.id
}

# Web NACL
resource "aws_network_acl" "ibm-web-nacl" {
  vpc_id = aws_vpc.ibm-vpc.id
  
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
    Name = "ibm-web-nacl"
  }
}

# Database NACL
resource "aws_network_acl" "ibm-db-nacl" {
  vpc_id = aws_vpc.ibm-vpc.id
  
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
    Name = "ibm-db-nacl"
  }
}

# Web NACL Association
resource "aws_network_acl_association" "ibm-web-nacl-asc" {
  network_acl_id = aws_network_acl.ibm-web-nacl.id
  subnet_id      = aws_subnet.ibm-web-sn.id
}

# Database NACL Association
resource "aws_network_acl_association" "ibm-db-nacl-asc" {
  network_acl_id = aws_network_acl.ibm-db-nacl.id
  subnet_id      = aws_subnet.ibm-db-sn.id
}

# Web Security Group
resource "aws_security_group" "ibm-web-sg" {
  name        = "ibm-web-traffic"
  description = "Allow SSH - HTTP inbound traffic"
  vpc_id      = aws_vpc.ibm-vpc.id

  ingress {
    description = "SSH from WWW"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from WWW"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ibm-web-sg"
  }
}

# Database Security Group
resource "aws_security_group" "ibm-db-sg" {
  name        = "ibm-db-traffic"
  description = "Allow SSH - Postgres inbound traffic"
  vpc_id      = aws_vpc.ibm-vpc.id

  ingress {
    description = "SSH from WWW"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "Postgres from WWW"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ibm-db-sg"
  }
}
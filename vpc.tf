resource "aws_vpc" "main" {
  cidr_block            = var.vpc["cidr_block"]
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags                  = var.vpc["tags"]
}

resource "aws_internet_gateway" "gw" {
  vpc_id  = aws_vpc.main.id
  tags    = var.gw["tags"]
}



resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.privatesubnet1["cidr_block"]
  availability_zone       = var.privatesubnet1["availability_zone"]
  map_public_ip_on_launch = false
  tags                    = var.privatesubnet1["tags"]
  
}


resource "aws_subnet" "private_subnet2" {
  vpc_id                    = aws_vpc.main.id
  cidr_block                = var.privatesubnet2["cidr_block"]
  availability_zone         = var.privatesubnet2["availability_zone"]
  map_public_ip_on_launch   = false
  tags                      = var.privatesubnet2["tags"]
}


resource "aws_subnet" "public_subnet1" {
    vpc_id                  = aws_vpc.main.id 
    cidr_block              = var.publicsubnet1["cidr_block"]
    availability_zone       = var.publicsubnet1["availability_zone"]
    map_public_ip_on_launch = true
    tags                    = var.publicsubnet1["tags"]
}


resource "aws_subnet" "public_subnet2" {
    vpc_id                  = aws_vpc.main.id 
    cidr_block              = var.publicsubnet2["cidr_block"]
    availability_zone       = var.publicsubnet2["availability_zone"]
    map_public_ip_on_launch = true
    tags                    = var.publicsubnet2["tags"]
}

resource "aws_eip" "eip" {
    vpc      = true
}

resource "aws_nat_gateway" "natgateway" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.public_subnet1.id
    tags          = var.natgateway["tags"]
    depends_on    = [
            aws_internet_gateway.gw,
            aws_route_table.publicroutetable,
            aws_subnet.private_subnet1, 
            aws_subnet.private_subnet2]
}

resource "aws_route_table" "publicroutetable" {
    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }
    tags   = var.publicroutetable["tags"]
}

resource "aws_route_table" "privateroutetable" {
    vpc_id   = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.natgateway.id
    }
    tags    = var.privateroutetable["tags"]
}

resource "aws_route_table_association" "publicroutetableassociation1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.publicroutetable.id
}

resource "aws_route_table_association" "publicroutetableassociation2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.publicroutetable.id
}


resource "aws_route_table_association" "privateroutetableassociation1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.privateroutetable.id
}

resource "aws_route_table_association" "privateroutetableassociation2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.privateroutetable.id
}




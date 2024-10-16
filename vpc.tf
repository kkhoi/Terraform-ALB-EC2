# VPC
resource "aws_vpc" "webserver_vpc" {
  cidr_block = "10.0.0.0/16"
}
# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.webserver_vpc.id
  count             = length(var.vpc_az) #Số lượng subnet sẽ được tạo
  cidr_block        = cidrsubnet(aws_vpc.webserver_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_az, count.index)
  tags = {
    Name = "Public subnet ${count.index + 1}"
  }
}
# private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.webserver_vpc.id
  count             = length(var.vpc_az)
  cidr_block        = cidrsubnet(aws_vpc.webserver_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc_az, count.index)
  tags = {
    Name = "Private subnet ${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "webserver_igw" {
  vpc_id = aws_vpc.webserver_vpc.id
  tags = {
    Name = "Webserver-Internet Gateway"
  }
}

# route table for public subnet
resource "aws_route_table" "route_table_public_subnet" {
  vpc_id = aws_vpc.webserver_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webserver_igw.id
  }
  tags = {
    Name = "Public subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.route_table_public_subnet.id
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}
# Elastic IP
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.webserver_igw]
}
# NAT GW
resource "aws_nat_gateway" "webserver_natgateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
  depends_on    = [aws_internet_gateway.webserver_igw]
  tags = {
    Name = "Webserver-Nat Gateway"
  }
}
# route table for private subnet
resource "aws_route_table" "route_table_private_subnet" {
  depends_on = [aws_nat_gateway.webserver_natgateway]
  vpc_id     = aws_vpc.webserver_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.webserver_natgateway.id
  }
  tags = {
    Name = "Private subnet Route Table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.route_table_private_subnet.id
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}
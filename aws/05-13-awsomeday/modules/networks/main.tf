# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    env = "demo"
  }
}

resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    env = "demo"
  }
}

resource "aws_subnet" "app_public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az0

  tags = {
    env = "demo"
  }
}

resource "aws_route_table" "app_public_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_igw.id
  }

  tags = {
    env = "demo"
  }
}

resource "aws_route_table_association" "app_public_asso" {
  subnet_id      = aws_subnet.app_public.id
  route_table_id = aws_route_table.app_public_route.id
}

resource "aws_route_table" "app_private_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    env = "demo"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "app_private0_asso" {
  subnet_id      = aws_subnet.app_private0.id
  route_table_id = aws_route_table.app_private_route.id
}

resource "aws_route_table_association" "app_private1_asso" {
  subnet_id      = aws_subnet.app_private1.id
  route_table_id = aws_route_table.app_private_route.id
}


resource "aws_subnet" "app_private0" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.az0

  tags = {
    env = "demo"
  }
}

resource "aws_subnet" "app_private1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.az1

  tags = {
    env = "demo"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.app_public.id

  tags = {
    Name = "nat gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main_vpc_igw]
}


resource "aws_eip" "nat_eip" {
  vpc = true
}

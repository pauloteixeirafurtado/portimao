resource "aws_vpc" "portimao" {
  cidr_block                           = "172.16.0.0/16"
  tags                                 = {
    "Name" = "portimao"
  }
}

resource "aws_subnet" "por_public1" {
  availability_zone                              = "us-west-2a"
  cidr_block                                     = "172.16.0.0/20"
  tags                                           = {
    "Name" = "portimao-subnet-por_public1-us-west-2a"
  }
  vpc_id                                         = aws_vpc.portimao.id
}

resource "aws_subnet" "por_public2" {
  availability_zone                              = "us-west-2b"
  cidr_block                                     = "172.16.16.0/20"
  tags                                           = {
    "Name" = "portimao-subnet-por_public1-us-west-2a"
  }
  vpc_id                                         = aws_vpc.portimao.id
}

resource "aws_internet_gateway" "portimao-igw" {
  tags     = {
    "Name" = "portimao-igw"
  }
  vpc_id   = aws_vpc.portimao.id
}

resource "aws_route_table" "por_public" {
  vpc_id = aws_vpc.portimao.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portimao-igw.id
  }
  tags             = {
    "Name" = "portimao-rtb-public"
  }
}

resource "aws_route_table_association" "por_public1" {
  route_table_id = aws_route_table.por_public.id
  subnet_id      = aws_subnet.por_public1.id
}

resource "aws_route_table_association" "por_public2" {
  route_table_id = aws_route_table.por_public.id
  subnet_id      = aws_subnet.por_public2.id
}

resource "aws_vpc_endpoint" "portimao-vpce-s3" {
  policy                = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
      Version   = "2008-10-17"
    }
  )
  service_name          = "com.amazonaws.us-west-2.s3"
  tags                  = {
    "Name" = "portimao-vpce-s3"
  }
  vpc_endpoint_type     = "Gateway"
  vpc_id                = aws_vpc.portimao.id
}

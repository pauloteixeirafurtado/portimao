resource "aws_vpc" "pontadelgada" {
  cidr_block                           = "10.0.0.0/16"
  tags                                 = {
    "Name" = "pontadelgada"
  }
}

resource "aws_subnet" "pdl_private1" {
  availability_zone                              = "us-west-2a"
  cidr_block                                     = "10.0.1.0/24"
  tags                                           = {
    "Name" = "pontadelgada-subnet-pdl_private1-us-west-2a"
  }
  vpc_id                                         = aws_vpc.pontadelgada.id
}

resource "aws_subnet" "pdl_private2" {
  availability_zone                              = "us-west-2a"
  cidr_block                                     = "10.0.2.0/24"
  tags                                           = {
    "Name" = "pontadelgada-subnet-pdl_private2-us-west-2a"
  }
  vpc_id                                         = aws_vpc.pontadelgada.id
}

resource "aws_subnet" "pdl_public1" {
  availability_zone                              = "us-west-2a"
  cidr_block                                     = "10.0.0.0/24"
  tags                                           = {
    "Name" = "pontadelgada-subnet-pdl_public1-us-west-2a"
  }
  vpc_id                                         = aws_vpc.pontadelgada.id
}

resource "aws_internet_gateway" "pontadelgada-igw" {
  tags     = {
    "Name" = "pontadelgada-igw"
  }
  vpc_id   = aws_vpc.pontadelgada.id
}

resource "aws_route_table" "pdl_private1" {
  tags             = {
    "Name" = "pontadelgada-rtb-pdl_private1-us-west-2a"
  }
  vpc_id           = aws_vpc.pontadelgada.id
}

resource "aws_route_table" "pdl_private2" {
  tags             = {
    "Name" = "pontadelgada-rtb-pdl_private2-us-west-2a"
  }
  vpc_id           = aws_vpc.pontadelgada.id
}

resource "aws_route_table" "pdl_public1" {
  vpc_id = aws_vpc.pontadelgada.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pontadelgada-igw.id
  }
  tags             = {
    "Name" = "pontadelgada-rtb-public"
  }
}

resource "aws_route_table_association" "pdl_private1" {
  route_table_id = aws_route_table.pdl_private1.id
  subnet_id      = aws_subnet.pdl_private1.id
}

resource "aws_route_table_association" "pdl_private2" {
  route_table_id = aws_route_table.pdl_private2.id
  subnet_id      = aws_subnet.pdl_private2.id
}

resource "aws_route_table_association" "pdl_public1" {
  route_table_id = aws_route_table.pdl_public1.id
  subnet_id      = aws_subnet.pdl_public1.id
}

resource "aws_vpc_endpoint" "pontadelgada-vpce-s3" {
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
  route_table_ids       = [
    aws_route_table.pdl_private1.id,
    aws_route_table.pdl_private2.id,
  ]
  service_name          = "com.amazonaws.us-west-2.s3"
  tags                  = {
    "Name" = "pontadelgada-vpce-s3"
  }
  vpc_endpoint_type     = "Gateway"
  vpc_id                = aws_vpc.pontadelgada.id
}

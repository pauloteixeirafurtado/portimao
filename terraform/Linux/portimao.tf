resource "aws_vpc" "Portimao" {
  cidr_block                           = "172.16.0.0/16"
  tags                                 = {
    "Name" = "Portimao"
  }
}

resource "aws_subnet" "por_public1" {
  availability_zone                              = "us-west-2a"
  cidr_block                                     = "172.16.0.0/20"
  tags                                           = {
    "Name" = "Portimao-subnet-por_public1-us-west-2a"
  }
  vpc_id                                         = aws_vpc.Portimao.id
}

resource "aws_internet_gateway" "Portimao-igw" {
  tags     = {
    "Name" = "Portimao-igw"
  }
  vpc_id   = aws_vpc.Portimao.id
}

resource "aws_route_table" "por_public" {
  vpc_id = aws_vpc.Portimao.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Portimao-igw.id
  }
  tags             = {
    "Name" = "Portimao-rtb-public"
  }
}

resource "aws_route_table_association" "por_public1" {
  route_table_id = aws_route_table.por_public.id
  subnet_id      = aws_subnet.por_public1.id
}

resource "aws_vpc_endpoint" "Portimao-vpce-s3" {
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
    "Name" = "Portimao-vpce-s3"
  }
  vpc_endpoint_type     = "Gateway"
  vpc_id                = aws_vpc.Portimao.id
}

resource "aws_security_group" "por_default" {
  description = "Portimao default VPC security group"
  egress      = [
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress     = [
    {
      cidr_blocks      = [
        "192.168.0.0/16",
        "172.16.0.0/12",
        "10.0.0.0/8",
      ]
      description      = "RFC 1918"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
  ]
  name        = "por_default"
  tags        = {
    "Name" = "Portimao"
  }
  vpc_id      = aws_vpc.Portimao.id
}

resource "aws_vpc_security_group_ingress_rule" "por_home" {
  cidr_ipv4              = "128.65.243.205/32"
  description            = "Home"
  ip_protocol            = "-1"
  security_group_id      = aws_security_group.por_default.id
  tags                   = {
    "Name" = "Home IP address"
  }
}

resource "aws_instance" "luxsql_portimao_pt" {
  ami                                  = var.deb_based
  instance_type                        = "t2.small"
  key_name                             = "vokeyoregon"
  subnet_id                            = aws_subnet.por_public1.id
  tags                                 = {
    "Name" = "luxsql.portimao.pt"
  }
  vpc_security_group_ids               = [
    aws_security_group.por_default.id,
  ]
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for winswl.portimao.pt"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.luxsql-portimao-pt.rendered
}

resource "aws_eip" "luxssql_portimao_public_ip" {
  vpc                       = true
  instance                  = aws_instance.luxsql_portimao_pt.id
  tags                                 = {
    "Name" = "Portimao public IP"
  }
  depends_on = [
    aws_instance.luxsql_portimao_pt
  ]
}
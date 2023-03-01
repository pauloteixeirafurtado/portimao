resource "aws_vpc" "Lisboa" {
  cidr_block                           = "192.168.0.0/16"
  tags                                 = {
    "Name" = "Lisboa"
  }
}

resource "aws_subnet" "lis_private1" {
  availability_zone                              = var.avail_zone
  cidr_block                                     = "192.168.1.0/24"
  tags                                           = {
    "Name" = "Lisboa-subnet-lis_private1"
  }
  vpc_id                                         = aws_vpc.Lisboa.id
}

resource "aws_subnet" "lis_private2" {
  availability_zone                              = var.avail_zone
  cidr_block                                     = "192.168.2.0/24"
  tags                                           = {
    "Name" = "Lisboa-subnet-lis_private2"
  }
  vpc_id                                         = aws_vpc.Lisboa.id
}

resource "aws_subnet" "lis_public1" {
  availability_zone                              = var.avail_zone
  cidr_block                                     = "192.168.0.0/24"
  tags                                           = {
    "Name" = "Lisboa-subnet-lis_public1"
  }
  vpc_id                                         = aws_vpc.Lisboa.id
}

resource "aws_internet_gateway" "Lisboa-igw" {
  tags     = {
    "Name" = "Lisboa-igw"
  }
  vpc_id   = aws_vpc.Lisboa.id
}

resource "aws_route_table" "lis_private1" {
  tags             = {
    "Name" = "Lisboa-rtb-lis_private1"
  }
  vpc_id           = aws_vpc.Lisboa.id
}

resource "aws_route_table" "lis_private2" {
  tags             = {
    "Name" = "Lisboa-rtb-lis_private2"
  }
  vpc_id           = aws_vpc.Lisboa.id
}

resource "aws_route_table" "lis_public1" {
  vpc_id = aws_vpc.Lisboa.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Lisboa-igw.id
  }
  tags             = {
    "Name" = "Lisboa-rtb-public"
  }
}

resource "aws_route_table_association" "lis_private1" {
  route_table_id = aws_route_table.lis_private1.id
  subnet_id      = aws_subnet.lis_private1.id
}

resource "aws_route_table_association" "lis_private2" {
  route_table_id = aws_route_table.lis_private2.id
  subnet_id      = aws_subnet.lis_private2.id
}

resource "aws_route_table_association" "lis_public1" {
  route_table_id = aws_route_table.lis_public1.id
  subnet_id      = aws_subnet.lis_public1.id
}

resource "aws_vpc_endpoint" "Lisboa-vpce-s3" {
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
    aws_route_table.lis_private1.id,
    aws_route_table.lis_private2.id,
  ]
  service_name          = var.vpc_ep_svc_name
  tags                  = {
    "Name" = "Lisboa-vpce-s3"
  }
  vpc_endpoint_type     = "Gateway"
  vpc_id                = aws_vpc.Lisboa.id
}

resource "aws_security_group" "lis_default" {
  description = "Lisboa default VPC security group"
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
  name        = "lis_default"
  tags        = {
    "Name" = "Lisboa"
  }
  vpc_id      = aws_vpc.Lisboa.id
}

resource "aws_vpc_security_group_ingress_rule" "lis_home" {
  cidr_ipv4              = "128.65.243.205/32"
  description            = "Home"
  ip_protocol            = "-1"
  security_group_id      = aws_security_group.lis_default.id
  tags                   = {
    "Name" = "Home IP address"
  }
}

resource "aws_instance" "srv_lis_local" {
  ami                                  = var.windows_server
  instance_type                        = "t2.small"
  key_name                             = "vokeyoregon"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.srv_lis_public1.id
  }
  tags                                 = {
    "Name" = "srv.lis.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for srv.lis.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.srv-lis-local.rendered
}

resource "aws_network_interface" "srv_lis_private1" {
  private_ips         = ["192.168.1.10"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_private1.id
  tags                                 = {
    "Name" = "Lisboa private1 interface"
  }
  attachment {
    device_index  = 1
    instance      = aws_instance.srv_lis_local.id
  }
}

resource "aws_network_interface" "srv_lis_private2" {
  private_ips         = ["192.168.2.10"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_private2.id
  tags                                 = {
    "Name" = "Lisboa private2 interface"
  }
  attachment {
    device_index  = 2
    instance      = aws_instance.srv_lis_local.id
  }
}

resource "aws_network_interface" "srv_lis_public1" {
  private_ips         = ["192.168.0.10"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_public1.id
  tags                                 = {
    "Name" = "Lisboa public interface"
  }
}

resource "aws_eip" "lis_public_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.srv_lis_public1.id
  tags                                 = {
    "Name" = "Lisboa public IP"
  }
  depends_on = [
    aws_instance.srv_lis_local
  ]
}

resource "aws_instance" "winsrv_lis_local" {
  ami                                  = var.windows_server
  instance_type                        = "t2.small"
  key_name                             = "vokeyoregon"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.winsrv_lis_private1.id
  }
  tags                                 = {
    "Name" = "winsrv.lis.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for winsrv.lis.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.winsrv-lis-local.rendered
}

resource "aws_network_interface" "winsrv_lis_private1" {
  private_ips         = ["192.168.1.100"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_private1.id
  tags                                 = {
    "Name" = "Lisboa winsrv private interface"
  }
}

resource "aws_instance" "windmz_lis_local" {
  ami                                  = var.windows_server
  instance_type                        = "t2.small"
  key_name                             = "vokeyoregon"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.windmz_lis_private2.id
  }
  tags                                 = {
    "Name" = "windmz.lis.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for windmz.lis.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.windmz-lis-local.rendered
}

resource "aws_network_interface" "windmz_lis_private2" {
  private_ips         = ["192.168.2.100"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_private2.id
  tags                                 = {
    "Name" = "Lisboa windmz private interface"
  }
}

resource "aws_instance" "maria_lis_local" {
  ami                                  = var.windows_server
  instance_type                        = "t2.small"
  key_name                             = "vokeyoregon"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.maria_lis_private1.id
  }
  tags                                 = {
    "Name" = "maria.lis.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for maria.lis.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.maria-lis-local.rendered
}

resource "aws_network_interface" "maria_lis_private1" {
  private_ips         = ["192.168.1.101"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_private1.id
  tags                                 = {
    "Name" = "Lisboa maria private interface"
  }
}

resource "aws_instance" "manuel_lis_local" {
  ami                                  = var.windows_server
  instance_type                        = "t2.small"
  key_name                             = "vokeyoregon"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.manuel_lis_private1.id
  }
  tags                                 = {
    "Name" = "manuel.lis.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for manuel.lis.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.manuel-lis-local.rendered
}

resource "aws_network_interface" "manuel_lis_private1" {
  private_ips         = ["192.168.1.102"]
  security_groups    = [
    aws_security_group.lis_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.lis_private1.id
  tags                                 = {
    "Name" = "Lisboa manuel private interface"
  }
}
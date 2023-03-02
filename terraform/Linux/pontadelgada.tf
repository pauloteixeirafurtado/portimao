resource "aws_key_pair" "redes" {
  key_name   = "Redes"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2W6MG+b8k9HKNMRyQksi+S2XBryBNK9uj4DkXu542Hf4hd32zCFnlNbik3EDOE8EKeg8S6IvJGdTeBLYraxize2tm5DMGz6LMeWmyK+OK/EDxYtRpJMXC7Dk3rbRdsRZyvqqmQmP5hJEV5A0zLUYwgm6cIxGa1a+671AG2cX170qbmdb3OzajlccaEIq0QexBoBM2kDpu3kG4aeLKShbp9Pjj290tRFvVMEqwi8Ay8KdQY8Sg1f8QTdJe9F5icACm4SLkfTiSw0sB7nDInNj3R4/Q7yn4Hx65K5uG8jXUGTsHdWcFgrm/naWJ3yfxoNOQayZlX44lL4rsiy7w/HPZR2MBFcYAJxfDG0Pam6fXnQr7MHZ/XK0QaP2vvPbmlifPaJQMEAfOvZxhRS7CLmFawbqokxsO+62ADB/38ycxD0Hq2Q1LF9+f4f17Tq8JRssYFkdzM63l0tnQhbyZM6g+J3VMgovSHu3jBHLZ9wIhilndQvQNtecIqVGzGposdBp0c/USF4km12xk/RXsQnWnbp+8fNcdiSF3dkF0p+dIdfHIuTH5GnmzP9187K3FZu0gueQJuU5Lx0IP+6TEZgSrDJgElx6PJCPzIv6/2OL3QdmhzwcFN3L/xq0GF4GMGxeGGouVQjRKo+Q3u3PLezVoAgAlnAd3qAikP82VA2358w=="
}

resource "aws_vpc" "PontaDelgada" {
  cidr_block                           = "10.0.0.0/16"
  tags                                 = {
    "Name" = "PontaDelgada"
  }
}

resource "aws_subnet" "pdl_private1" {
  availability_zone                              = var.avail_zone
  cidr_block                                     = "10.0.1.0/24"
  tags                                           = {
    "Name" = "PontaDelgada-subnet-pdl_private1"
  }
  vpc_id                                         = aws_vpc.PontaDelgada.id
}

resource "aws_subnet" "pdl_private2" {
  availability_zone                              = var.avail_zone
  cidr_block                                     = "10.0.2.0/24"
  tags                                           = {
    "Name" = "PontaDelgada-subnet-pdl_private2"
  }
  vpc_id                                         = aws_vpc.PontaDelgada.id
}

resource "aws_subnet" "pdl_public1" {
  availability_zone                              = var.avail_zone
  cidr_block                                     = "10.0.0.0/24"
  tags                                           = {
    "Name" = "PontaDelgada-subnet-pdl_public1"
  }
  vpc_id                                         = aws_vpc.PontaDelgada.id
}

resource "aws_internet_gateway" "PontaDelgada-igw" {
  tags     = {
    "Name" = "PontaDelgada-igw"
  }
  vpc_id   = aws_vpc.PontaDelgada.id
}

resource "aws_route_table" "pdl_private1" {
  tags             = {
    "Name" = "PontaDelgada-rtb-pdl_private1"
  }
  vpc_id           = aws_vpc.PontaDelgada.id
}

resource "aws_route_table" "pdl_private2" {
  tags             = {
    "Name" = "PontaDelgada-rtb-pdl_private2"
  }
  vpc_id           = aws_vpc.PontaDelgada.id
}

resource "aws_route_table" "pdl_public1" {
  vpc_id = aws_vpc.PontaDelgada.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PontaDelgada-igw.id
  }
  tags             = {
    "Name" = "PontaDelgada-rtb-public"
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

resource "aws_vpc_endpoint" "PontaDelgada-vpce-s3" {
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
  service_name          = var.vpc_ep_svc_name
  tags                  = {
    "Name" = "PontaDelgada-vpce-s3"
  }
  vpc_endpoint_type     = "Gateway"
  vpc_id                = aws_vpc.PontaDelgada.id
}

resource "aws_security_group" "pdl_default" {
  description = "PontaDelgada default VPC security group"
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
  name        = "pdl_default"
  tags        = {
    "Name" = "PontaDelgada"
  }
  vpc_id      = aws_vpc.PontaDelgada.id
}

resource "aws_vpc_security_group_ingress_rule" "pdl_home" {
  cidr_ipv4              = "128.65.243.205/32"
  description            = "Home"
  ip_protocol            = "-1"
  security_group_id      = aws_security_group.pdl_default.id
  tags                   = {
    "Name" = "Home IP address"
  }
}

resource "aws_vpc_security_group_ingress_rule" "pdl_enta" {
  cidr_ipv4              = "185.218.12.73/32"
  description            = "ENTA"
  ip_protocol            = "-1"
  security_group_id      = aws_security_group.pdl_default.id
  tags                   = {
    "Name" = "ENTA IP address"
  }
}

resource "aws_instance" "luxsrv_pdl_local" {
  ami                                  = var.deb_based
  instance_type                        = "t2.small"
  key_name                             = aws_key_pair.redes.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.luxsrv_pdl_public1.id
  }
  tags                                 = {
    "Name" = "luxsrv.pdl.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for luxsrv.pdl.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.luxsrv-pdl-local.rendered
}

resource "aws_network_interface" "luxsrv_pdl_private1" {
  private_ips         = ["10.0.1.10"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_private1.id
  tags                                 = {
    "Name" = "PontaDelgada private1 interface"
  }
  attachment {
    device_index  = 1
    instance      = aws_instance.luxsrv_pdl_local.id
  }
}

resource "aws_network_interface" "luxsrv_pdl_private2" {
  private_ips         = ["10.0.2.10"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_private2.id
  tags                                 = {
    "Name" = "PontaDelgada private2 interface"
  }
  attachment {
    device_index  = 2
    instance      = aws_instance.luxsrv_pdl_local.id
  }
}

resource "aws_network_interface" "luxsrv_pdl_public1" {
  private_ips         = ["10.0.0.10"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_public1.id
  tags                                 = {
    "Name" = "PontaDelgada public interface"
  }
}

resource "aws_eip" "pdl_public_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.luxsrv_pdl_public1.id
  tags                                 = {
    "Name" = "PontaDelgada public IP"
  }
  depends_on = [
    aws_instance.luxsrv_pdl_local
  ]
}

resource "aws_instance" "deb_pdl_local" {
  ami                                  = var.deb_based
  instance_type                        = "t2.small"
  key_name                             = aws_key_pair.redes.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.deb_pdl_private2.id
  }
  tags                                 = {
    "Name" = "deb.pdl.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for deb.pdl.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.deb-pdl-local.rendered
}

resource "aws_network_interface" "deb_pdl_private2" {
  private_ips         = ["10.0.2.101"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_private2.id
  tags                                 = {
    "Name" = "PontaDelgada deb_pdl private interface"
  }
}

resource "aws_instance" "rh_pdl_local" {
  ami                                  = var.rh_based
  instance_type                        = "t2.small"
  key_name                             = aws_key_pair.redes.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.rh_pdl_private2.id
  }
  tags                                 = {
    "Name" = "rh.pdl.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for rh.pdl.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.rh-pdl-local.rendered
}

resource "aws_network_interface" "rh_pdl_private2" {
  private_ips         = ["10.0.2.102"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_private2.id
  tags                                 = {
    "Name" = "PontaDelgada rh_pdl private interface"
  }
}

resource "aws_instance" "debcli_pdl_local" {
  ami                                  = var.deb_based
  instance_type                        = "t2.small"
  key_name                             = aws_key_pair.redes.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.debcli_pdl_private1.id
  }
  tags                                 = {
    "Name" = "debcli.pdl.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for debcli.pdl.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.debcli-pdl-local.rendered
}

resource "aws_network_interface" "debcli_pdl_private1" {
  private_ips         = ["10.0.1.101"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_private1.id
  tags                                 = {
    "Name" = "PontaDelgada maria private interface"
  }
}

resource "aws_instance" "rhcli_pdl_local" {
  ami                                  = var.rh_based
  instance_type                        = "t2.small"
  key_name                             = aws_key_pair.redes.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.rhcli_pdl_private2.id
  }
  tags                                 = {
    "Name" = "rhcli.pdl.local"
  }
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for rhcli.pdl.local"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = data.template_file.rhcli-pdl-local.rendered
}

resource "aws_network_interface" "rhcli_pdl_private2" {
  private_ips         = ["10.0.1.102"]
  security_groups    = [
    aws_security_group.pdl_default.id,
  ]
  source_dest_check  = false
  subnet_id          = aws_subnet.pdl_private1.id
  tags                                 = {
    "Name" = "PontaDelgada rhcli private interface"
  }
}
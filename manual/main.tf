resource "aws_instance" "winsql" {
  availability_zone                    = "us-west-2a"
  instance_type                        = "t2.small"
  key_name                             = "vockeyoregon"
  subnet_id                            = "subnet-09ed1f6db9a49cf48"
  tags                                 = {
    "Name" = "winsql.Portimao.pt"
  }
  vpc_security_group_ids               = [
    "sg-0f5708a849709127a",
  ]
  root_block_device {
    delete_on_termination = true
    tags                                 = {
      "Name" = "Volume for winswl.Portimao.pt"
    }
    volume_size           = 30
    volume_type           = "gp2"
  }
}

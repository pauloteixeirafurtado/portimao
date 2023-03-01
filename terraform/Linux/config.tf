data "template_file" "luxsrv-pdl-local" {
  template = <<EOF
#!/bin/bash
hostnamectl set-hostname luxsrv.pdl.local
apt-get update
apt-get upgrade
EOF
}

data "template_file" "deb-pdl-local" {
  template = <<EOF
#!/bin/bash
hostnamectl set-hostname deb.pdl.local
apt-get update
apt-get upgrade
EOF
}

data "template_file" "rh-pdl-local" {
  template = <<EOF
#!/bin/bash
hostnamectl set-hostname rh.pdl.local
yum -y update
EOF
}

data "template_file" "debcli-pdl-local" {
  template = <<EOF
#!/bin/bash
hostnamectl set-hostname debcli.pdl.local
apt-get update
apt-get upgrade
EOF
}

data "template_file" "rhcli-pdl-local" {
  template = <<EOF
#!/bin/bash
hostnamectl set-hostname luxsrv.pdl.local
yum -y update
EOF
}

data "template_file" "luxsql-portimao-pt" {
  template = <<EOF
#!/bin/bash
hostnamectl set-hostname luxsrv.pdl.local
apt-get update
apt-get upgrade
EOF
}

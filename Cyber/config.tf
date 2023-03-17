data "template_file" "desktop" {
  template = <<EOF
#!/bin/bash
LOGFILE="/var/log/cloud-config-"$(date +%s)
SCRIPT_LOG_DETAIL="$LOGFILE"_$(basename "$0").log
# Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$SCRIPT_LOG_DETAIL 2>&1
hostnamectl set-hostname desktop
apt-get update
apt-get upgrade
apt install -y xfce4 xfce4-goodies
apt install -y xrdp filezilla
apt install -y mysql-workbench-community
snap connect mysql-workbench-community:password-manager-service :password-manager-service
snap install brave
snap install thunderbird
adduser xrdp ssl-cert
echo xfce4-session > /home/ubuntu/.xsession
chown ubuntu:ubuntu /home/ubuntu/.xsession
systemctl enable --now xrdp
EOF
}

data "template_file" "onion" {
  template = <<EOF
#!/bin/bash
LOGFILE="/var/log/cloud-config-"$(date +%s)
SCRIPT_LOG_DETAIL="$LOGFILE"_$(basename "$0").log
# Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$SCRIPT_LOG_DETAIL 2>&1
hostnamectl set-hostname onion
apt-get update
apt-get upgrade
apt install -y xfce4 xfce4-goodies
apt install -y xrdp filezilla
snap install brave
adduser xrdp ssl-cert
echo xfce4-session > /home/ubuntu/.xsession
chown ubuntu:ubuntu /home/ubuntu/.xsession
systemctl enable --now xrdp
EOF
}
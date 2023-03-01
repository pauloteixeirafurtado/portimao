data "template_file" "srv-lis-local" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "srv" -Force;
$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
Set-LocalUser administrator -Password $Secure_String_Pwd
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

data "template_file" "winsrv-lis-local" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "winsrv" -Force;
$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
Set-LocalUser administrator -Password $Secure_String_Pwd
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

data "template_file" "windmz-lis-local" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "windmz" -Force;
$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
Set-LocalUser administrator -Password $Secure_String_Pwd
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

data "template_file" "maria-lis-local" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "maria" -Force;
$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
Set-LocalUser administrator -Password $Secure_String_Pwd
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

data "template_file" "manuel-lis-local" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "manuel" -Force;
$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
Set-LocalUser administrator -Password $Secure_String_Pwd
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

data "template_file" "winsql-Portimao-pt" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "winsql" -Force;
$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
Set-LocalUser administrator -Password $Secure_String_Pwd
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}

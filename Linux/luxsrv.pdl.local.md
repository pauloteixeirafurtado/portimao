```
apt update && apt -y upgrade && reboot
```

```
apt install netfilter-persistent iptables-persistent easy-rsa 
apt install bind9 bind9-utils bind9-doc resolvconf dnsutils
```

```
# cat /etc/bind/named.conf.local 
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "pdl.local" {
        type master;
        file "/var/lib/bind/db.pdl.local";
        allow-update { none; };
};

zone "portugal.pt" {
        type master;
        file "/var/lib/bind/db.portugal.pt";
        allow-update { none; };
};

zone "Portimao.pt" {
        type master;
        file "/var/lib/bind/db.Portimao.pt";
        allow-update { none; };
};

zone "0.10.in-addr.arpa." {
        type master;
        file "/var/lib/bind/db.0.10";
        allow-update { none; };
};
```

```
# cat /etc/bind/named.conf.options 
options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable 
        // nameservers, you probably want to use them as forwarders.  
        // Uncomment the following block, and insert the addresses replacing 
        // the all-0's placeholder.

        forwarders {
                8.8.8.8;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation no;
        auth-nxdomain no;
        allow-recursion { any; };
        listen-on-v6 { none; };
};
```

**Criar ficheiros em /var/lib/bind e confirmar owner:group**

```
# ls -l /var/lib/bind
total 16
-rw-r--r-- 1 root bind 716 Feb 25 11:05 db.0.10
-rw-r--r-- 1 root bind 497 Feb 24 23:34 db.pdl.local
-rw-r--r-- 1 root bind 405 Feb 25 11:06 db.Portimao.pt
-rw-r--r-- 1 root bind 405 Feb 25 11:06 db.portugal.pt
```

```
# cat db.0.10
;
; BIND reverse data file for local loopback interface
;
$TTL    604800
@       IN      SOA     pdl.local. root.pdl.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.
100.0   IN      PTR     ns.
100.1   IN      PTR     ns.
100.2   IN      PTR     ns.
100.0   IN      PTR     luxsrv.
100.1   IN      PTR     luxsrv.
100.2   IN      PTR     luxsrv.
102.2   IN      PTR     rh.
101.2   IN      PTR     deb.
102.1   IN      PTR     rhcli.
101.1   IN      PTR     debcli.
100.2   IN      PTR     ns.portugal.pt
101.2   IN      PTR     ns.portugal.pt
102.2   IN      PTR     ns.portugal.pt
101.2   IN      PTR     www.portugal.pt
101.2   IN      PTR     smtp.portugal.pt
100.2   IN      PTR     ns.Portimao.pt
101.2   IN      PTR     ns.Portimao.pt
102.2   IN      PTR     ns.Portimao.pt
102.2   IN      PTR     www.Portimao.pt
102.2   IN      PTR     smtp.Portimao.pt
```

```
# cat db.pdl.local
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     pdl.local. root.pdl.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.
@       IN      A       192.168.0.100
@       IN      A       192.168.1.100
@       IN      A       192.168.2.100
ns      IN      A       192.168.0.100
ns      IN      A       192.168.1.100
ns      IN      A       192.168.2.100
rh      IN      A       192.168.2.102
deb     IN      A       192.168.2.101
rhcli   IN      A       192.168.1.102
debcli  IN      A       192.168.1.101
luxsrv  IN      A       192.168.0.100
luxsrv  IN      A       192.168.1.100
luxsrv  IN      A       192.168.2.100
```

```
# cat db.Portimao.pt
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     Portimao.pt. root.Portimao.pt. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.
@       IN      MX      10      smtp
@       IN      A       192.168.0.100
@       IN      A       192.168.1.100
@       IN      A       192.168.2.100
ns      IN      A       192.168.0.100
ns      IN      A       192.168.1.100
ns      IN      A       192.168.2.100
www     IN      A       192.168.2.102
smtp    IN      A       192.168.2.102
```

```
# cat db.portugal.pt
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     portugal.pt. root.portugal.pt. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.
@       IN      MX      10      smtp
@       IN      A       192.168.0.100
@       IN      A       192.168.1.100
@       IN      A       192.168.2.100
ns      IN      A       192.168.0.100
ns      IN      A       192.168.1.100
ns      IN      A       192.168.2.100
www     IN      A       192.168.2.101
smtp    IN      A       192.168.2.101
```

** Configurar IPTABLES**

```
# cat /etc/iptables/rules.v4
# Generated by iptables-save v1.8.7 on Fri Feb 24 22:58:32 2023
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p tcp --dport 3389 -j DNAT --to-destination 192.168.1.101
-A PREROUTING -i eth0 -p tcp --dport 3390 -j DNAT --to-destination 192.168.1.102:3389
-A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to-destination 192.168.2.102:80
-A PREROUTING -i eth0 -p tcp --dport 8443 -j DNAT --to-destination 192.168.2.102:443
-A PREROUTING -i eth0 -p tcp -m multiport --dports 80,443 -j DNAT --to-destination 192.168.2.101
-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT
# Completed on Fri Feb 24 22:58:32 2023
```

**Configure DNS on netplan**

Caso seja Red Hat: https://aws.amazon.com/premiumsupport/knowledge-center/ec2-static-dns-ubuntu-debian/

```
root@luxsrv:/etc/netplan# cat 50-cloud-init.yaml 
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        eth0:
            dhcp4: true
            dhcp4-overrides:
                route-metric: 100
                use-dns: false
            nameservers:
                search: [pdl.local]
                addresses: [192.168.0.100]
            dhcp6: false
            match:
                macaddress: 12:ce:3f:9f:f0:d1
            set-name: eth0
        eth1:
            dhcp4: true
            dhcp4-overrides:
                route-metric: 200
                use-dns: false
            nameservers:
                search: [pdl.local]
                addresses: [192.168.1.100]
            dhcp6: false
            match:
                macaddress: 12:1c:08:bc:79:1b
            set-name: eth1
        eth2:
            dhcp4: true
            dhcp4-overrides:
                route-metric: 300
                use-dns: false
            nameservers:
                search: [pdl.local]
                addresses: [192.168.2.100]
            dhcp6: false
            match:
                macaddress: 12:d5:13:3f:36:b3
            set-name: eth2
    version: 2
```

**Install Asterisk**

```
# No debcli.pdl.local
sudo apt-get install --reinstall libgtk2.0-0
```

```
apt install asterisk

nano /etc/asterisk/sip.conf

# Colocar no fim do ficheiro

[101]
type=friend
host=dynamic
secret=101

[102]
type=friend
host=dynamic
secret=102


nano /etc/asterisk/extensions.conf

#Encontrar o contexto [public] e adicionar duas linhas

[public]
; 
; ATTENTION: If your Asterisk is connected to the internet and you do
; not have allowguest=no in sip.conf, everybody out there may use your
; public context without authentication.  In that case you want to
; double check which services you offer to the world.
;
include => demo

exten => 101,1,Dial(SIP/101,30)
exten => 102,1,Dial(SIP/102,30)

#Restart
sudo systemctl enable --now asterisk
sudo systemctl status asterisk
```

**Certificados**
```
cd /etc
cp -R /usr/share/easy-rsa/ .
cd easy-rsa/
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req www.portugal.pt nopass
./easyrsa gen-req www.Portimao.pt nopass
./easyrsa --subject-alt-name="DNS:www.portugal.pt" sign-req server www.portugal.pt
./easyrsa --subject-alt-name="DNS:www.Portimao.pt" sign-req server www.Portimao.pt
```
Instalar o CA nos clientes e copiar os certificados para os servidores; forma mais fácil instalar o apache2 e colocar na raiz:
```
  343  apt install apache2
  344  cd /var/www/html/
  345  ls -l
  346  rm index.html 
  347  cp /etc/easy-rsa/pki/ca.crt .
  348  cp /etc/easy-rsa/pki/issued/www.portugal.pt.crt .
  349  cp /etc/easy-rsa/pki/issued/www.Portimao.pt.crt .
  350  cp /etc/easy-rsa/pki/private/www.portugal.pt.key .
  351  cp /etc/easy-rsa/pki/private/www.Portimao.pt.key .
  ```



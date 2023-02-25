**Install easy-rsa**
```
sudo apt install easy-rsa
sudo cp -R /usr/share/easy-rsa/ /etc/easy-rsa
cd /etc/easy-rsa/
sudo sed -i 's/serverAuth/serverAuth,clientAuth/g' x509-types/server
sudo ./easyrsa init-pki
sudo ./easyrsa build-ca nopass
sudo ./easyrsa gen-req etcd nopass
sudo ./easyrsa --subject-alt-name="IP:127.0.0.1,IP:172.31.56.101,IP:172.31.56.102,IP:172.31.56.103" sign-req server etcd
cd ~
sudo cp /etc/easy-rsa/pki/issued/etcd.crt .
sudo cp /etc/easy-rsa/pki/private/etcd.key .
sudo cp /etc/easy-rsa/pki/ca.crt .
sudo chown ubuntu:ubuntu *
nano bootstrap_etcd_cluster 
chmod +x bootstrap_etcd_cluster
./bootstrap_etcd_cluster
nano CloudComputing.pem
chmod 600 CloudComputing.pem
scp -i CloudComputing.pem * 172.31.56.102:
scp -i CloudComputing.pem * 172.31.56.102:

# No 172.31.56.102 editar bootstrap_etcd_cluster e correr ./bootstrap_etcd_cluster
# No 172.31.56.103 editar bootstrap_etcd_cluster e correr ./bootstrap_etcd_cluster
```
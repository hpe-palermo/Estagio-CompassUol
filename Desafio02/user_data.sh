#!/bin/bash

# Variáveis de ambiente
export ENDERECO_EFS="fs-0b3c3a8dfa74ffbe8.efs.us-east-1.amazonaws.com"
export WORDPRESS_DB_HOST="database-1.c1ue0wu6y89k.us-east-1.rds.amazonaws.com"
export WORDPRESS_DB_USER="admin"
export WORDPRESS_DB_PASSWORD="nduhr02-02ffk4"
export WORDPRESS_DB_NAME="db_wp"

# Instalar Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start

# Instalar Docker Compose
sudo su
sudo chmod 777 /usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Instalar NFS
sudo yum -y install nfs-utils
sudo systemctl enable nfs-utils
sudo systemctl start nfs-utils

# Montagem do sistema de arquivos
sudo mkdir -p /mnt/dados
sudo chmod -R 777 /mnt/dados
echo "#
UUID=3a8023d8-2841-47f7-985b-ab4b5825ae27     /           xfs    defaults,noatime  1   1
UUID=A012-E846        /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt,x-systemd.automount 0 2
$ENDERECO_EFS:/ /mnt/dados nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" | sudo tee  /etc/fstab
sudo mount -a

# Iniciar o WordPress com Docker Compose
cat <<EOF > docker-compose.yml
version: '3.9'

services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: $WORDPRESS_DB_HOST
      WORDPRESS_DB_USER: $WORDPRESS_DB_USER
      WORDPRESS_DB_PASSWORD: $WORDPRESS_DB_PASSWORD
      WORDPRESS_DB_NAME: $WORDPRESS_DB_NAME
    volumes:
      - /mnt/dados:/var/www/html
EOF

# Subir aplicação
docker-compose down
docker-compose up -d

touch feito.txt

# Instalr MySQL
# sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
# sudo yum install mysql80-community-release-el9-1.noarch.rpm -y 
# sudo yum install mysql-community-server -y
# sudo systemctl start mysqld
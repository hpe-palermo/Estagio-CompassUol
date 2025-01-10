#!/bin/bash

touch iniciando-instalacao.txt
# Variáveis de ambiente
export ENDERECO_EFS="fs-069a7f7a85ca8acec.efs.us-east-1.amazonaws.com"
export WORDPRESS_DB_HOST="database-1.c1ue0wu6y89k.us-east-1.rds.amazonaws.com"
export WORDPRESS_DB_USER="admin"
export WORDPRESS_DB_PASSWORD="nduhr02-02ffk4"
export WORDPRESS_DB_NAME="db_wp"
export DIRETORIO_EFS="/mnt/dados"

# Instalar Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start
touch docker-instalado.txt

#
UUID=3a8023d8-2841-47f7-985b-ab4b5825ae27     /           xfs    defaults,noatime  1   1
UUID=A012-E846        /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt,x-systemd.automount 0 2
fs-069a7f7a85ca8acec.efs.us-east-1.amazonaws.com:/ /mnt/dados nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0

# Instalar Docker Compose
sudo chmod 777 /usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
touch docker-compose-instalado.txt

# Instalar NFS
sudo yum -y install nfs-utils
sudo systemctl start nfs-utils
sudo systemctl enable nfs-utils
touch nfs-instalado.txt

# Montagem do sistema de arquivos
sudo mkdir -p $DIRETORIO_EFS
sudo chmod -R 777 $DIRETORIO_EFS
echo "$ENDERECO_EFS:/ $DIRETORIO_EFS nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" | sudo tee -a /etc/fstab
sudo mount -a
touch efs-montado.txt

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
      - $DIRETORIO_EFS:/var/www/html
EOF
touch yml-escrito.txt

# Subir aplicação
sudo docker-compose down
sudo docker-compose up -d

touch feito-v11.txt
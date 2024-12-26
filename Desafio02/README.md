# Desafio 02 - Projeto: Implantação de WordPress na AWS

![alt text](image.png)

## Introdução

Este projeto demonstra a configuração e o deployment de uma aplicação WordPress utilizando serviços da AWS, criando uma infraestrutura escalável e altamente disponível.

## Arquitetura do Projeto

- **Duas Instâncias de Servidor WordPress:**

  - Contêineres que hospedam a aplicação WordPress.
  - Compartilham os arquivos estáticos via Amazon EFS para garantir consistência entre as instâncias.  

- **Amazon RDS (Relational Database Service):**

  - Serviço gerenciado de banco de dados utilizado para armazenar os dados do WordPress, como configurações, posts e usuários.  

- **Load Balancer:**

  - Balanceador de carga da AWS que distribui o tráfego entre as instâncias do WordPress, garantindo alta disponibilidade e escalabilidade.  

- **Amazon EFS (Elastic File System):**

  - Sistema de arquivos compartilhado utilizado para armazenar arquivos estáticos do WordPress (uploads, temas e plugins), acessível simultaneamente por todas as instâncias.

## Criação e configuração dos recursos

Nesta etapa, são demonstradas as configurações dos recursos necessários para a criação da arquitetura do projeto e sua execução/inicialização.

- **VPC**

  - Nome da instância: my-vpc
  - Faixa de IPs para permitir a criação de sub redes: 10.0.0.0/16
  - VPC criada!

- **Internet Gateway**

  - Nome da instância: my-internet-gateway
  - Anexar à VPC `my-vpc`
  - IGW criado!

- **Security Groups**

  - **Grupo de segurança para o Bastion Host:**
    - Nome: my-sec-grp-bastion
    - Portas de entrada:

    | Tipo  | Protocolo |  Porta |         Origem           |
    |-------|-----------|--------|--------------------------|
    | SSH   |    TCP    |   22   |        0.0.0.0/0         |

  - **Grupo de segurança para as instâncias:**
    - Nome: my-sec-grp-private
    - Portas de entrada:
    
    |     Tipo     | Protocolo |  Porta |         Origem           |
    |--------------|-----------|--------|--------------------------|
    | All Traffic  |    TCP    |   80   |    my-sec-grp-bastion    |
    |     HTTP     |    TCP    |   80   |      my-sec-grp-alb      |
    |     SSH      |    TCP    |   22   |        0.0.0.0/0         |
  - **Grupo de segurança para o RDS:**
    - Portas de entrada:
    
    |      Tipo      | Protocolo | Porta |           Origem              |
    |----------------|-----------|-------|-------------------------------|
    | MySQL/Aurora   |    TCP    |  3306 |       my-sec-grp-private      |
  - **Grupo de segurança para o EFS:**
    - Portas de entrada:
    
    | Tipo  | Protocolo | Porta |         Origem            |
    |-------|-----------|-------|---------------------------|
    |  NFS  |    TCP    | 2049  |     my-sec-grp-private    |
  - **Grupo de segurança para o Load Balancer:**
    - Nome: my-sec-grp-lb
  - Portas de entrada:
    
    | Tipo  | Protocolo |  Porta |  Origem   |
    |-------|-----------|--------|-----------|
    | HTTP  |    TCP    |   80   | 0.0.0.0/0 |

- **Subnets**

  - |      Nome     | Faixa de IP |     AZ     |
    |---------------|-------------|------------|
    | sn-public-01  | 10.0.1.0/24 | us-east-1a |
    | sn-public-02  | 10.0.2.0/24 | us-east-1b |
    | sn-private-01 | 10.0.3.0/24 | us-east-1a |
    | sn-private-02 | 10.0.4.0/24 | us-east-1b |
  
- **NAT Gateway:**

  - Nome: my-nat
  - Subnet: sn-public-01
  - Connectivity type: public
  - Atribuir IP Elástico

- **Route Table**

  - |     Nome    |            Subnets           |       Saída      |
    |-------------|------------------------------|------------------|
    | rt-public   | sn-public-01, sn-public-02   | Internet Gateway |
    | rt-private  | sn-private-01, sn-private-02 | NAT Gateway      |

- **EFS**

  - Nome da instância (opcional): my-efs
  - VPC: my-vpc
  - EFS criado!
  - Selecione a instância
  - Clique em "Attach"
  - Copie o ID

- **RDS**

  - Nome da instância: database-1
  - Banco: MySQL
  - Tipo de instância: t3.micro
  - Autenticação
    - Usuário: admin
    - Senha: minha-senha
  - Tabela no banco: minha-tabela
  - VPC: my-vpc
  - RDS criado!

- **Bastion Host**

  - Nome: bastion
  - Grupo de segurança: my-sec-grp-bastion


- **Auto Scalling Group**
  - Nome: my-asg
  - Template: my-template
  - VPC: my-vpc
  - Subnets: sn-private-01, sn-private-02
  - VPC: my-vpc
  - AZ: sn-private-01, sn-private-02
  - Criar o Load Balancer
    - Nome: my-load-balancer
    - Grupo de Segurança: my-sec-grp-alb
    - Target Group: my-target-group
    - Subnets: sn-subnet-01, sn-subnet-02
    - Load Balancer criado!
  - Criar o Target Group
      - Nome: my-target-group
      - Target Group criado!
  - Group Size:
    - Desired: 2
    - Minimum: 2
    - Maximum: 2

- **Launch Template**
  
  - Nome: my-template
  - Versão: v1
  - Tipo: t3.micro
  - VPC: my-vpc
  - Grupo de Segurança: my-sec-grp-private
  - Adicionar o user_data.sh
  - Template Criado!!

## Script de Inicialização

O script de inicialização (user_data.sh) para instalação automática do Docker, configuração do docker-compose.yml para a criação dos containers do WordPress.

```bash
#!/bin/bash

# Variáveis de ambiente
export ENDERECO_EFS="<ENDERECO_EFS>"
export WORDPRESS_DB_HOST="<WORDPRESS_DB_HOST>"
export WORDPRESS_DB_USER="<WORDPRESS_DB_USER>"
export WORDPRESS_DB_PASSWORD="<WORDPRESS_DB_PASSWORD>"
export WORDPRESS_DB_NAME="<WORDPRESS_DB_NAME>"
export DIRETORIO_VOLUME="/mnt/dados"

# Instalar Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start

# Instalar Docker Compose
sudo su
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Instalar NFS
sudo yum -y install nfs-utils
sudo systemctl enable nfs-utils
sudo systemctl start nfs-utils

# Montagem do sistema de arquivos
sudo mkdir -p $DIRETORIO_VOLUME
sudo chmod -R 777 $DIRETORIO_VOLUME
echo "#
UUID=3a8023d8-2841-47f7-985b-ab4b5825ae27     /           xfs    defaults,noatime  1   1
UUID=A012-E846        /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt,x-systemd.automount 0 2
$ENDERECO_EFS:/ $DIRETORIO_VOLUME nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" | sudo tee  /etc/fstab
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
      - $DIRETORIO_VOLUME:/var/www/html
EOF

# Subir aplicação
docker-compose down
docker-compose up -d

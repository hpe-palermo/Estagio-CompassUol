#!/bin/bash

# Definir diretório de saída
output_dir="."
online_file="$output_dir/nginx_online.log"
offline_file="$output_dir/nginx_offline.log"

# Pegar data e hora atuais
current_time=$(date "+%Y-%m-%d %H:%M:%S")

# Verificar status do Nginx
status=$(systemctl is-active nginx)

# Se o Nginx estiver online
if [ "$status" = "active" ]; then
    echo "$current_time - nginx - ONLINE - Nginx está online!" >> $online_file
else
    echo "$current_time - nginx - OFFLINE - Nginx está offline!" >> $offline_file
fi
./script.sh


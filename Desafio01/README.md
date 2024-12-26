


# Subir um servidor Nginx e verificar seu status

Neste projeto, é demonstado o passo a passo para criar e levantar um servidor nginx no ambiente Linux. 

### Criar um ambiente Linux no Windows com WSL

Instale WSL no Windows com o seguinte comando:
```
wls --install -d Ubuntu	
```
  

### Iniciar serviço

Para iniciar e utilizar o WSL:

- Aperte a tecla `win`  e digite "wsl"

  
### Criar e levantar servidor

Para criar o servisdor, devemos instalar ao pacote `nginx`:
```
apt update
apt upgrade
apt-get install nginx
```
*Nota: é uma boa prática atualizar os pacotes!*
  

###  Ajustando o firewall

`ufw` é um programa de firewall que simplifica a configuração de um firewall em distribuições GNU/Linux, como o Ubuntu e o Debian.  Para listar as possíveis configurações de tráfego, execute:
```
ufw app list
```
A saída deve ser semelhante a esta:
```
Available applications:
  Nginx Full
  Nginx HTTP
  Nginx HTTPS
```
  Para este exemplo, será utilizado 'Nginx HTTP'.

### **Verificar o status**

```
ufw status
```
Se a saída mostrar 'active', está tudo ok! Caso contrário, pode ser que o serviço esteja desabilitado. Habilite com:

```
ufw enable
```

### Verificar status do servidor 

```
systemctl status nginx
```

Se retornar "active", pode ser que outro serviço esteja utilizando a porta 80(como o Apache). Neste caso, pare o serviço.

### Testando 

Abra o navegador e digite 'localhost' ou abra o terminal e digite `curl localhost`. Deverá retornar a página padrão do Nginx.



### Criar um script que valide se o serviço está online e envie o resultado da validação para um diretório que você definir.

- Validar se o serviço está online:
	```bash
	status=$(systemctl is-active nginx)
	```
- O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline:
	``` bash
	if [ "$status" == "active" ]; then
	    echo "$current_time - nginx - ONLINE - Nginx is running." >> $online_file
	else
	    echo "$current_time - nginx - OFFLINE - Nginx is not running!" >> $offline_file
	fi
	```
- O script deve gerar 2 arquivos de saída: 1 para o serviço online e 1 para o serviço OFFLINE:
	```bash
	output_dir="."
	online_file="$output_dir/nginx_online.log"
	offline_file="$output_dir/nginx_offline.log"
	``` 
-  Preparar a execução automatizada do
script a
cada 5 minutos
	```
	crontab -e
 	```

- No arquivo, adicione:
	 ```
	*/5 * * * * sh script.sh
 	```
- Conceda a permissão para executar:
	 ```
	chmod +x script.sh 
	```

	
### Fazer o versionamento da atividade

-	Iniciando um repositório:
	
	```
	git init
	```
-	Adicionar os arquivos ao repositório:
	
	```
	git add .
	```
-	Fazendo `commit`:
	
	```
	git commit -m "atividade finalizada"
	```
-	Renomeando a branch `master` para `main`:
	
	```
	git branch -M main
	```
-	Apontar o repositório local para o repositório remoto:
	
	```
	git remote add origin https://github.com/hpe-palermo/estagio-compass-uol
	```

-	Enviando para o repositório remoto:
	
	```
	git push -u origin main
	```	


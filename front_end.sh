#!/bin/bash

# ------------------------------------------------------------------------------ Front end -----------------------------------------------------------------------------------------------
# Configuracion del scritp
# Ruta donde guardamos el archivo .htpasswd
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
# Definimos la contraseña de root pada DB
DB_ROOT_PASSWD=root
# IP Servidor MySQL
IPPRIVADA=172.31.27.177

# ------------------------------------------------------------------------------ Instalación de la Apache ------------------------------------------------------------------------------ 
# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x
# Actualizamos la lista de paquetes
apt update
apt upgrade -y
# Instalamos el servidor web Apache -y le decimos que si
apt install apache2 -y
# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y

# ------------------------------------------------------------------------------ Instalación aplicación web ------------------------------------------------------------------------------ 
# Clonamos el repositorio de la aplicación
cd /var/www/html 
rm -rf iaw-practica-lamp 
git clone https://github.com/josejuansanchez/iaw-practica-lamp

# Movemos el contenido del repositorio al home de html
mv /var/www/html/iaw-practica-lamp/src/*  /var/www/html/

# Configuramos el archivo php de la aplicacion
sed -i "s/localhost/$IPPRIVADA/" /var/www/html/config.php

# Eliminamos el archivo Index.html de apache
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp/

# Cambiamos permisos 
chown www-data:www-data * -R

# ------------------------------------------------------------------------------ Inslación de herramientas adicionales --------------------------------------------------------------------
# Descargamos Adminer
mkdir /var/www/html/adminer 
cd /var/www/html/adminer 
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php 
mv adminer-4.7.7-mysql.php index.php

# Instalación de GoAccess
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list 
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add - 
apt-get update 
apt-get install goaccess -y

# Creamos el directorio stats.
mkdir /var/www/html/stats

# Lazamos el proceso en segundo plano
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -c -b $HTTPASSWD_DIR/.htpasswd $HTTPASSWD_USER $HTTPASSWD_PASSWD

# Instalamos unzip
apt install unzip -y
# Instalación de Phpmyadmin
cd /home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-lenguages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-lenguages.zip
# Descomprimimos 
nzip phpMyAdmin-5.0.4-all-lenguages.zip
# Borramos el archivo .zip
rm -rf phpMyAdmin-5.0.4-all-lenguages.zip
# Movemos la carpeta al directorio
mv phpMyAdmin-5.0.4-all-lenguages /var/www/html/phpmyadmin
# Configuaramos el archivo config.sample.inc.php
cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/$IPPRIVADA/" /var/www/html/config.inc.php

# Cambiamos permisos de /var/www/html
cd /var/www/html
chown www-data:www-data * -R

# Copiamos el archivo de configuracion de apache
cp /home/ubuntu/000-default.conf /etc/apache2/sites-available/
systemctl restart apache2

# Opcional, instalamos cliente MySQL
# apt install mysql-client-core-8.0




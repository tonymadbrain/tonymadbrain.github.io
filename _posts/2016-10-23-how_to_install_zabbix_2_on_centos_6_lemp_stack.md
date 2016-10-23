---
layout: post
title: Установка Zabbix 2.2 на CentOS 6.5 + LEMP
excerpt: "Заметки из redmine"
permalink: /how_to_install_zabbix_2_on_centos_6_lemp_stack/
tags:
  - Zabbix
  - Centos
  - Tutorial
  - Nginx
  - Mysql
  - Php
date: 2016-10-23T13:19:26+03:00
---

> У меня в redmine лежат заметки, к которым не обращаюсь, но выглядят они полезными, поэтому перенесу их сюда, как бы в архив.

{% include _toc.html %}

# Установка zabbix-server

Добавляем репозиторий zabbix

{% highlight bash %}
$ rpm -ivh http://repo.zabbix.com/zabbix/2.0/rhel/6/x86_64/zabbix-release-2.0-1.el6.noarch.rpm
{% endhighlight %}

Устанавливаем zabbix-server

{% highlight bash %}
$ yum install zabbix-server-mysql zabbix-web-mysql -y
{% endhighlight %}

Отключаем репозиторий zabbix

{% highlight bash %}
# enabled=1 => enabled=0
$ vim /etc/yum.repos.d/zabbix.repo
{% endhighlight %}

# Установка MySQL

Добавляем репозиторий epel

{% highlight bash %}
$ rpm -ivh http://mirror.yandex.ru/epel/6/x86_64/epel-release-6-8.noarch.rpm
{% endhighlight %}

Устанавливаем MySQL cервер и консоль

{% highlight bash %}
$ yum install mysql-server mysql-client -y
{% endhighlight %}

Запускаем демон базы данных

{% highlight bash %}
$ service mysqld start
{% endhighlight %}

# Создание базы данных

Логинимся под рутом

{% highlight bash %}
mysql -uroot
{% endhighlight %}

Создаем БД и пользователя

{% highlight bash %}
> create database zabbix character set utf8; grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'; exit
{% endhighlight %}

Переходим в папку с дампами бд от zabbix

{% highlight bash %}
$ cd /usr/share/doc/zabbix-server-mysql-2.0.11/create/
{% endhighlight %}

Восстанавливаем таблицы из дампов

{% highlight bash %}
$ mysql -uroot zabbix < schema.sql mysql -uroot zabbix < images.sql mysql -uroot zabbix < data.sql
{% endhighlight %}

Устанавливаем свои пароли mysql для пользователей root и zabbix

{% highlight bash %}
$ mysql -uroot SET PASSWORD = PASSWORD('root_pass'); exit mysql -uzabbix -pzabbix SET PASSWORD = PASSWORD('zabbix_pass'); exit
{% endhighlight %}

# Конфигурирование Zabbix

Правим конфиг zabbix

{% highlight bash %}
$ vim /etc/zabbix/zabbix_server.conf
{% endhighlight %}

Проверяем следующие параметры:

{% highlight bash %}
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix_pass
{% endhighlight %}

Запускаем сервер zabbix

{% highlight bash %}
$ service zabbix-server start
{% endhighlight %}

# Установка и настройка PHP

Устанавливаем пакеты

{% highlight bash %}
$ yum install php php-mysql php-mbstring php-mcrypt gcc libtool php-fpm php-cli php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-pecl-apc snmp sysstat -y
{% endhighlight %}

Правим настройки PHP

{% highlight bash %}
$ vim /etc/php.ini
{% endhighlight %}

{% highlight bash %}
php_value max_execution_time 300
php_value max_input_time 300
php_value memory_limit 128M //дефолт
php_value post_max_size 16M
php_value upload_max_filesize 2M //дефолт
//раскомментировать строку и подставить Europe/Moscow
date.timezone = Europe/Moscow
{% endhighlight %}

# Установка и настройка NGINX

Инсталим nginx

{% highlight bash %}
$ yum install nginx -y
{% endhighlight %}

Создаем папку для резервных копий

{% highlight bash %}
$ mkdir /home/backups/
{% endhighlight %}

Перемещаем все дефолтные конфиги

{% highlight bash %}
$ mv /etc/nginx/conf.d/default.conf /home/backups/ mv /etc/nginx/conf.d/virtual.conf /home/backups/ mv /etc/nginx/nginx.conf /home/backups/
{% endhighlight %}

Создаем новый конфиг nginx

{% highlight bash %}
$ vim /etc/nginx/nginx.conf
{% endhighlight %}

{% highlight bash %}
user nginx;
worker_processes 10;
pid /var/run/nginx.pid;
events {
  worker_connections 1024;
  use epoll;
  multi_accept on;
}
error_log /var/log/nginx/error.log warn;
http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';
  access_log /var/log/nginx/access.log main;
  connection_pool_size 256;
  client_header_buffer_size 4k;
  client_max_body_size 100m;
  large_client_header_buffers 8 8k;
  request_pool_size 4k;
  output_buffers 1 32k;
  postpone_output 1460;
  proxy_max_temp_file_size 0;
  gzip on;
  gzip_min_length 1024;
  gzip_proxied any;
  gzip_proxied expired no-cache no-store private auth;
  gzip_types text/plain text/xml application/xml application/x-javascript text/javascript text/css text/json;
  gzip_comp_level 8;
  gzip_disable «MSIE [1-6]\.(?!.*SV1)»;
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 75 20;
  server_names_hash_max_size 8192;
  ignore_invalid_headers on;
  server_name_in_redirect off;
  proxy_buffer_size 8k;
  proxy_buffers 32 4k;
  proxy_connect_timeout 1000;
  proxy_read_timeout 12000;
  proxy_send_timeout 12000;
  proxy_cache_path /var/cache/nginx levels=2 keys_zone=pagecache:5m inactive=10m max_size=50m;
  real_ip_header X-Real-IP;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  allow all;
  include /etc/nginx/conf.d/*.conf;
}
{% endhighlight %}

Создаем конфиг виртуального сервера для zabbix'a

{% highlight bash %}
vim /etc/nginx/conf.d/zabbix.conf
{% endhighlight %}

{% highlight bash %}
server {
  listen 80;
  server_name zabbix.hostname.ru;

  location / {
    root /usr/share/zabbix;
    index index.php index.html index.htm;
  }

  location ~ \.php$ {
    root /usr/share/zabbix;
    try_files $uri =404;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_buffers 4 256k;
    fastcgi_busy_buffers_size 256k;
    fastcgi_temp_file_write_size 256k;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
  }

  # deny access to .htaccess files, if Apache's document root concurs with nginx's one
  location ~ /\.ht {
    deny all;
  }
}
{% endhighlight %}

# Последние штрихи

Удаляем предустановленный apache из автозапуска

{% highlight bash %}
$ chkconfig httpd off
{% endhighlight %}

Добавляем в автозагрузку nginx, php-fpm, mysqld и zabbix

{% highlight bash %}
$ chkconfig --levels 235 nginx on
$ chkconfig --levels 235 php-fpm on
$ chkconfig --levels 235 mysqld on
$ chkconfig zabbix-server on
{% endhighlight %}

Стопаем apache и запускаем все наши сервисы

{% highlight bash %}
$ service httpd stop
$ service nginx start
$ service php-fpm start
$ service mysqld restart
{% endhighlight %}













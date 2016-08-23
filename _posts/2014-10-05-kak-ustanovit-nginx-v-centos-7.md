---
layout: post
title: Как установить Nginx в CentOS 7
date: '2014-10-05 16:04:55'
excerpt: ""
permalink: /how_to_install_nginx_in_centos_7/
redirect_from:
  - /kak-ustanovit-nginx-v-centos-7/
  - /how-to-install-nginx-in-centos-7/
tags:
  - Nginx
  - Centos
  - Linux
---

{% include _toc.html %}

Недавно, свет увидела новая версия популярного серверного дистрибутива CentOS, который базируется на RHEL, последняя релизная версия 7. Она включает много изменений, по сравнению с предыдущей версией 6.5.х. В этом мануале я расскажу, как установить веб-сервер Nginx в новой версии CentOS.

<br>
<img src="https://farm6.staticflickr.com/5763/21642651772_1028b812fb_o.png">
<br>
<br>

> Все действия выполняются на чистой системе и от суперпользователя (root).

### Установка

Установим репозиторий Nginx
{% highlight bash %}
$ cd /tmp
$ wget http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
$ rpm -ivh nginx-release-centos-7-0.el7.ngx.noarch.rpm
{% endhighlight %}

Установим Nginx

{% highlight bash %}
$ yum install nginx
{% endhighlight %}

### Обновление Nginx

В случае, если Nginx у вас уже установлен и необходимо его обновить, при условии установленного репозитория вы можете обновить его командой

{% highlight bash %}
$ yum update nginx
{% endhighlight %}

### Конфигурирование Nginx

Конфиг Nginx находится в каталоге `/etc/nginx`, где `/etc/nginx/nginx.conf` это основной конфигурационный файл. В общем случае, данный файл для CentOS 7 выглядит примерно так:

{% highlight bash %}
user  nginx;
worker_processes  8; # выставляется в зависимости от количества ядер
error_log  logs/error.log crit;

worker_rlimit_nofile  8192;

events {
worker_connections  800; # может придется увеличить при загруженном сервере
use epoll; #  Linux kernels 2.6.x
}

http {
server_names_hash_max_size 2048;
server_names_hash_bucket_size 512;

server_tokens off;

include    mime.types;
default_type  application/octet-stream;

sendfile on;
tcp_nopush on;
tcp_nodelay on;
keepalive_timeout  10;

# Включает сжатие Gzip
gzip on;
gzip_min_length  1100;
gzip_buffers  4 32k;
gzip_types    text/plain application/x-javascript text/xml text/css;

# Общие настройки и настройки тайм-аутов
ignore_invalid_headers on;
client_max_body_size    20m;
client_body_buffer_size 15m;
client_header_timeout  400;
client_body_timeout 400;
send_timeout     400;
connection_pool_size  256;
client_header_buffer_size 4k;
large_client_header_buffers 4 32k;
request_pool_size  4k;
output_buffers   4 32k;
postpone_output  1460;

# Кешируем наиболее часто запрашиваемые статические файлы
open_file_cache          max=10000 inactive=10m;
open_file_cache_valid    2m;
open_file_cache_min_uses 1;
open_file_cache_errors   on;

# Инклуд виртуальных хостов
include "/etc/nginx/conf.d/*.conf";
}
{% endhighlight %}

### Установка виртуального хоста

Вы можете создать ваш конфиг виртуального хоста (например для определенного домена) таким образом:

{% highlight bash %}
$ nano -w /etc/nginx/conf.d/yoursite.ru.conf
{% endhighlight %}

Но лично я предпочитаю текстовый редактор [Vim](http://www.vim.org/). Базовый конфиг виртуального хоста выглядит примерно так:

{% highlight bash %}
# firstsite.net
server {
  access_log off; # многие отключают логи доступа, говорят это снижает нагрузку
  log_not_found off; # я не из таких, но кому-то может пригодится
  error_log  logs/error_log warn;

  listen 80;
  server_name  firstsite.net;

  location / {
    root  /var/www/;
    index  index.php index.html index.htm;
  }

  location ~* .(gif|jpg|jpeg|png|ico|wmv|3gp|avi|mpg|mpeg|mp4|flv|mp3|mid|js|css|wml|swf)$ {
    root   /var/www/firstsite.net;
    expires max;
    add_header Pragma public;
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";
  }

  # PHP-FPM: раскомментировать, если используется php-fpm
  #location ~ .php$ {
  #  root           /var/www/firstsite.net;
  #  try_files $uri =404;
  #  fastcgi_pass   unix:/tmp/php5-fpm.sock;
  #  fastcgi_index  index.php;
  #  fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
  #  include        fastcgi_params;
  #  fastcgi_buffer_size 128k;
  #  fastcgi_buffers 256 4k;
  #  fastcgi_busy_buffers_size 256k;
  #  fastcgi_temp_file_write_size 256k;
  #}
}
{% endhighlight %}

### Управление сервисом Nginx

Для применения новых конфигурационных файлов попрежнему можно использовать команду:

{% highlight bash %}
service nginx reload
{% endhighlight %}

При этом появится сообщение: `Redirecting to /bin/systemctl reload  nginx.service`. Это потому, что в новой версии решили использовать `systemctl` и приучать к этому пользователей. Поэтому, добавление в автозагрузку теперь выглядит вот так:

{% highlight bash %}
$ systemctl enable nginx.service
ln -s '/usr/lib/systemd/system/nginx.service' '/etc/systemd/system/multi-user.target.wants/nginx.service'
{% endhighlight %}

Запуск демона вот так:

{% highlight bash %}
$ systemctl start nginx.service
{% endhighlight %}

А запрос статуса сервиса, вот так:

{% highlight bash %}
$ systemctl status nginx.service
nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled)
   Active: active (running) since Sun 2014-10-05 12:09:14 EDT; 7s ago
     Docs: http://nginx.org/en/docs/
  Process: 525 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
  Process: 522 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 526
   CGroup: /system.slice/nginx.service
           ├─526 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─527 nginx: worker process

Oct 05 12:09:14 centos7.host.ru nginx[522]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 05 12:09:14 centos7.host.ru nginx[522]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 05 12:09:14 centos7.host.ru systemd[1]: Failed to read PID from file /run/nginx.pid: Invalid argument
Oct 05 12:09:14 centos7.host.ru systemd[1]: Started nginx - high performance web server.
{% endhighlight %}




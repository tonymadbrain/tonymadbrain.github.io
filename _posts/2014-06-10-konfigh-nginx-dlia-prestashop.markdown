---
layout: post
title: Конфиг Nginx для Prestashop
date: '2014-06-10 12:18:40'
---

<img src="https://farm9.staticflickr.com/8595/16515667202_4ac4d6b26f_o.png" width="700"/>

<h4>PrestaShop</h4> - это open source, бесплатная, e-commerce CMS. В общем случае, моё знакомство с данным продуктом было не очень впечатляющим, в первый раз была ошибка с авторизацией администратора, после чистой установки, а во второй, административная панель не хотела открываться с 500 ошибкой, что, судя по логам, происходило из-за кривого шаблона, учитывая, что это была чистая установка. При этом, нормальной документации я не нашел, а все что есть сводится к тому, чтобы использовать их собственный клауд хостинг или хоститься у их партнеров.
Но, если кому-то понадобится конфиг для Nginx то вот он:
<pre>server {
access_log off;
error_log  logs/yoursite.com-error_log warn;

	listen 80;
        server_name  yoursite.com www.yoursite.com;
        root /var/www/yoursite.com;
        index index.php index.html;

       # PrestaShop rewrite rules
	rewrite ^/([a-z0-9]+)-([a-z0-9]+)(-[_a-zA-Z0-9-]*)/([_a-zA-Z0-9-]*).jpg$ /img/p/$1-$2$3.jpg last;
	rewrite ^/([0-9]+)-([0-9]+)/([_a-zA-Z0-9-]*).jpg$ /img/p/$1-$2.jpg last;
	rewrite ^/([0-9]+)(-[_a-zA-Z0-9-]*)/([_a-zA-Z0-9-]*).jpg$ /img/c/$1$2.jpg last;
	rewrite "^/lang-([a-z]{2})/([a-zA-Z0-9-]*)/([0-9]+)-([a-zA-Z0-9-]*).html(.*)$" /product.php?id_product=$3&amp;isolang=$1$5 last;
	rewrite "^/lang-([a-z]{2})/([0-9]+)-([a-zA-Z0-9-]*).html(.*)$" /product.php?id_product=$2&amp;isolang=$1$4 last;
	rewrite "^/lang-([a-z]{2})/([0-9]+)-([a-zA-Z0-9-]*)(.*)$" /category.php?id_category=$2&amp;isolang=$1 last;
	rewrite ^/([a-zA-Z0-9-]*)/([0-9]+)-([a-zA-Z0-9-]*).html(.*)$ /product.php?id_product=$2$4 last;
	rewrite ^/([0-9]+)-([a-zA-Z0-9-]*).html(.*)$ /product.php?id_product=$1$3 last;
	rewrite ^/([0-9]+)-([a-zA-Z0-9-]*)(.*)$ /category.php?id_category=$1 last;
	rewrite ^/content/([0-9]+)-([a-zA-Z0-9-]*)(.*)$ /cms.php?id_cms=$1 last;
	rewrite ^/([0-9]+)__([a-zA-Z0-9-]*)(.*)$ /supplier.php?id_supplier=$1$3 last;
	rewrite ^/([0-9]+)_([a-zA-Z0-9-]*)(.*)$ /manufacturer.php?id_manufacturer=$1$3 last;
	rewrite "^/lang-([a-z]{2})/(.*)$" /$2?isolang=$1 last;

	# static file cache configuration
	location ~* .(gif)$ {
	expires 2592000s;
	}
	location ~* .(jpeg|jpg)$ {
	expires 2592000s;
	}
	location ~* .(png)$ {
	expires 2592000s;
	}
	location ~* .(css)$ {
	expires 604800s;
	}
	location ~* .(js)$ {
	expires 604800s;
	}
	location ~* .(js)$ {
	expires 604800s;
	}
	location ~* .(ico)$ {
	expires 31536000s;
	}

	# php-fpm configuration
	location ~ .php$ {
	root /var/www/yoursite.com;
	try_files $uri =404;
	fastcgi_pass unix:/tmp/php5-fpm.sock;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	include fastcgi_params;
	fastcgi_buffer_size 128k;
	fastcgi_buffers 256 4k;
	fastcgi_busy_buffers_size 256k;
	fastcgi_temp_file_write_size 256k;
	}

}</pre>
Применить новый конфиг можно командой:
<pre>service nginx reload</pre>
<h4>Материалы по теме:</h4>
<ul>
	<li><a href="http://www.prestashop.com/ru" target="_blank">Официальный сайт</a></li>
</ul>
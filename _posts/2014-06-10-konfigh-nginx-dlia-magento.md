---
layout: post
title: Конфиг Nginx для Magento
date: '2014-06-10 12:29:03'
excerpt:
---

<img src="https://farm8.staticflickr.com/7408/16514983881_79a4865f03_o.jpg" alt="Magento-Logo"/>

<h4>Magento</h4> – это e-commerce CMS, с открытым исходным кодом (open source). Существует платная версия с поддержкой, а так же бесплатная, так называемая - community edition. На данный момент Magento Inc. принадлежит компании Ebay Inc., хотя начинали разработку украинские парни, работают сейчас, может и они же, но компания уже американская.

Magento считается самой эффективной и стабильной CMS для интернет-магазина. В своих бесконечных исследованиях, я, естественно, попробовал и её. Однако понял, что необходимо много времени на качественную работу с данной системой, и поэтому остановился на стадии знакомства.

Так как этот блог посвящен советам по Nginx, приведу конфиг для Magento:
<pre>server {
    listen   80;
    server_name domain.com www.domain.com;
    root   /var/www/domain.com;

    location / {
        index index.html index.php;

	try_files $uri $uri/ @handler;
        expires max; ## Максимальное время длительности кеша для файлов
	}

	## Закрываем системные каталоги
	    location ^~ /app/                { deny all; }
	    location ^~ /includes/           { deny all; }
	    location ^~ /lib/                { deny all; }
	    location ^~ /media/downloadable/ { deny all; }
	    location ^~ /pkginfo/            { deny all; }
	    location ^~ /report/config.xml   { deny all; }
	    location ^~ /var/                { deny all; }

	## Allow admins only to view export directory
	## Set up the password for any username using this command:
	## htpasswd -c /etc/nginx/htpasswd magentoadmin

	    location /var/export/ {
	        auth_basic           "Restricted";
	        auth_basic_user_file htpasswd; ## Defined at /etc/nginx/htpassword
	        autoindex            on;
	    }

	## Disable .htaccess and other hidden files
	    location  /. {
	        return 404;
	    }

	## Magento uses a common front handler
	    location @handler {
	        rewrite / /index.php;
	    }

	## Forward paths like /js/index.php/x.js to relevant handler
	    location ~ .php/ {
	        rewrite ^(.*.php)/ $1 last;
	    }

	## php-fpm parsing
	location ~ .php$ {

	## Catch 404s that try_files miss
        if (!-e $request_filename) { rewrite / /index.php last; }

	## Disable cache for php files
        expires        off;

	## конфигурация php-fpm с использованием сокетов
        fastcgi_pass   unix:/tmp/php5-fpm.sock;
        fastcgi_param  HTTPS $fastcgi_https;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;

	## Store code is located at Administration &gt; Configuration &gt; Manage Stores in your Magento Installation.
        fastcgi_param  MAGE_RUN_CODE default;
        fastcgi_param  MAGE_RUN_TYPE store;

	## Tweak fastcgi buffers, just in case.
	fastcgi_buffer_size 128k;
	fastcgi_buffers 256 4k;
	fastcgi_busy_buffers_size 256k;
	fastcgi_temp_file_write_size 256k;
	}
}
</pre>
Не забудьте заменить domain.com на ваше доменное имя, а так же выполнить
<pre> service nginx reload</pre>
чтобы конфиг подхватился.
<p></p>
<h4>Материалы по теме:</h4>
<ul>
	<li><a href="http://magento.com/" target="_blank">Официальный сайт</a></li>
</ul>

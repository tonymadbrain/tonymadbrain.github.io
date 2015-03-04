---
title: Знакомство с ImageCMS и update тестового сервера
layout: post
permalink: /znakomstvo-s-imagecms-i-update-testovogo-servera/
categories:
  - CentOS
  - root
tags:
  - CentOS
  - cms
  - e-commerce
  - imagecms
  - nginx
  - php
  - php-fpm
  - remi
  - update
---
&nbsp;

### <a href="http://res.cloudinary.com/doam-ru/image/upload/v1409069971/1391035277_image_cms_logo_0_r7auti.png" rel="lightbox[797]" title="1391035277_image_cms_logo_0"><img class="aligncenter wp-image-813 size-full" src="http://res.cloudinary.com/doam-ru/image/upload/v1409069971/1391035277_image_cms_logo_0_r7auti.png" alt="1391035277_image_cms_logo_0" width="800" height="226" /></a>Синапсис

В поисках CMS интернет-магазина (e-commerce) для нового проекта, нарвался на ImageCMS. Описание довольно привлекательное, однако именно интернет-магазин у них платный, и демо только на их серверах. Но другой их продукт &#8212; Corporate, полностью бесплатен, поэтому я решил затестить для начала его.

<!--more-->

### ImageCMS

Создатели данного продукта обещают:

  * Быстродействие
  * SEO-оптимизация
  * Безопасность
  * Юзабилити
  * Гибкость
  * Надежность

При этом, они рекомендуют использовать Denwer или OpenServer. Возникает резонный вопрос &#8212; неужели все вышеперечисленное мы получаем на Apache? Что же тогда будет под Nginx?

Вообще, особо много документации по установке вы не найдете. Не долго думая, я скачал последнюю версию 4.6 на сервер, и прописав обычный конфиг nginx+php-fpm, попробовал открыть главную. При этом, я увидел ошибку 404, а в адресной строке переадресацию на каталог install, которого в принципе нет в архиве с системой.

Стоит упомянуть что столкнувшись с данной ошибкой я полез в google, и по второй ссылке перешел на форум ImageCMS, в котором прочитал интересный тред:

> <div id="pc12204" class="title-h4">
>   Ne@Flax:
> </div>
> 
> <div class="title-h4">
>   Тема: Установка на NGINX без Апача
> </div>
> 
> <div class="entry-content">
>   Подскажите конфиг для NGINX без использования Апача.<br /> В частности, секции реврайтов.<br /> Сейчас установка ссылается на папку install, которой есстно и нет.</p> 
>   
>   <div id="pc12216" class="title-h4">
>     supleader:
>   </div>
>   
>   <div class="title-h4">
>     Re: Установка на NGINX без Апача
>   </div>
>   
>   <div class="entry-content">
>     У вас nginx+php-fpm? Вряд ли движок заведется&#8230;
>   </div>
> </div>

### htaccess-конвертер для nginx

На помощь приходит сервис из заголовка, который располагается например <a href="http://winginx.com/ru/htaccess" target="_blank">здесь</a>. Открываем файл .htaccess в корне каталога с ImageCMS, находим строки:

<pre>RewriteCond $1 !^(index.php|user_guide|uploads/.*|favicon.ico|docs|favicon.png|captcha/.*|application/modules/.*/templates|application/modules/.*/assets/js|application/modules/.*/assets/css|application/modules/.*/assets/images|CHANGELOG.xml|templates|js|robots.txt)
RewriteRule ^(.*)$ /index.php/$1 [L]</pre>

и с помощью вышеуказанного ресурса конвертируем это в удобоперевариваемое Nginx-ом:

<pre># nginx configuration
location / {
rewrite ^(.*)$ /index.php/$1 break;
}</pre>

На самом деле не очень удобоперевариваемое, поэтому переделываем так:

<pre>location / {
if (!-e $request_filename) {
rewrite ^(.+)$ /index.php?q=$1 last;
}</pre>

### Конфиг для Nginx

В итоге получаем простой конфиг, следующего вида:

<pre>server {
listen 80;
server_name mydomain.com;
access_log /var/log/nginx/access.log;
root /var/www/imagecms;
index index.php index.html index.htm;

location / {
if (!-e $request_filename) {
rewrite ^(.+)$ /index.php?q=$1 last;
}

}

location ~ .php$ {
fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME /var/www/imagecms$fastcgi_script_name;
include fastcgi_params;
}
}
</pre>

### Установка ImageCMS

После

<pre>service nginx reload</pre>

открываем главную страницу и &#171;о чудо&#187;, оно работает. Первым шагом установки является принятие лицензионного соглашения. Конечно не читая я нажимаю кнопку принять (или как-то так) и дальше следует проверка системы. Скрипт говорит, что все прекрасно, но вот версия PHP 4.3.3 меня не устраивает, хочу 4.3.4 минимум.

Что же, если хочешь &#8212; получай.

### Update тестового сервера

Естественно, что играюсь с разными системами я на тестовом сервере, который был скопирован с моего боевого сервера (т.е. да, там до сих пор стоит PHP 4.3.3) и обновляться не страшно.

Добавляем репозиторий Remi:

<pre>rpm -ihv http://rpms.famillecollet.com/enterprise/remi-release-6.rpm</pre>

Не забудьте включить его в /etc/yum.repos.d/remi.repo

Обновляемся:

<pre>yum update</pre>

И, не буду долго разглагольствовать. Что мне пришлось пофиксить:

PHP

<pre>/etc/php-fpm.d/www.conf

listen.owner = nginx

listen.group = nginx

; раскомментировать эти две строчки и прописать значения - пользователя из-под которого работает Nginx
</pre>

Так же сбросились права на папку /var/lib/php/session

<pre>cd /var/lib/php

chown nginx:nginx session
</pre>

Mysqld

<pre>/etc/my.cnf

#Новому Mysql не понравилось это:

default-character-set=utf8

#Просто закомментировал эту строчку
</pre>

После рестарта php-fpm и mysqld все заработало нормально.

### ImageCMS &#8212; итог

После обновления я закончил установку и теперь приступлю к тестированию данной CMS.

Минусы:

Отсутствие нормальной документации по установке на CentOS+Nginx+php-fpm.

Плюсы:

Данная CMS напомнила мне про необходимость обновления core пакетов веб-сервера.

Так же, я научился правильно создавать пользователей в mysql, но это к тексту не относится.

Материалы по теме:

  * <a href="http://www.imagecms.net/" target="_blank">Официальный сайт</a>
  * <a href="http://www.nginxtips.ru/znakomstvo-s-imagecms/" target="_blank">Статья взята с сайта</a>
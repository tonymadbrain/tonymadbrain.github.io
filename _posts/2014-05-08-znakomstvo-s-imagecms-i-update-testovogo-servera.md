---
title: Знакомство с ImageCMS и update тестового сервера
layout: post
permalink: /first_look_at_imagecms_and_update_test_stage/
redirect_from: /znakomstvo-s-imagecms-i-update-testovogo-servera/
excerpt: ""
tags:
  - CentOS
  - CMS
  - E-commerce
  - Imagecms
  - Nginx
  - Php
  - Php-fpm
  - Remi
  - Update
---

{% include _toc.html %}

<br>
<img src="https://farm1.staticflickr.com/725/21654039305_baf52d6c8a_o.png">
<br>
<br>

### Синапсис

В поисках CMS интернет-магазина (e-commerce) для нового проекта, нарвался на ImageCMS. Описание довольно привлекательное, однако именно интернет-магазин у них платный, и демо только на их серверах. Но другой их продукт &#8212; Corporate, полностью бесплатен, поэтому я решил затестить для начала его.

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

На помощь приходит сервис из заголовка, который располагается например <a href="http://winginx.com/ru/htaccess" target="_blank">здесь</a>. Открываем файл `.htaccess` в корне каталога с ImageCMS, находим строки:

{% highlight bash %}
RewriteCond $1 !^(index.php|user_guide|uploads/.*|favicon.ico|docs|favicon.png|captcha/.*|application/modules/.*/templates|application/modules/.*/assets/js|application/modules/.*/assets/css|application/modules/.*/assets/images|CHANGELOG.xml|templates|js|robots.txt)
RewriteRule ^(.*)$ /index.php/$1 [L]
{% endhighlight %}

и с помощью вышеуказанного ресурса конвертируем это в удобоперевариваемое Nginx-ом:

{% highlight bash %}
# nginx configuration
location / {
  rewrite ^(.*)$ /index.php/$1 break;
}
{% endhighlight %}

На самом деле не очень удобоперевариваемое, поэтому переделываем так:

{% highlight bash %}
location / {
  if (!-e $request_filename) {
    rewrite ^(.+)$ /index.php?q=$1 last;
  }
}
{% endhighlight %}

### Конфиг для Nginx

В итоге получаем простой конфиг, следующего вида:

{% highlight bash %}
server {
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
{% endhighlight %}

### Установка ImageCMS

После

{% highlight bash %}
$ service nginx reload
{% endhighlight %}

открываем главную страницу и &#171;о чудо&#187;, оно работает. Первым шагом установки является принятие лицензионного соглашения. Конечно не читая я нажимаю кнопку принять (или как-то так) и дальше следует проверка системы. Скрипт говорит, что все прекрасно, но вот версия PHP 4.3.3 меня не устраивает, хочу 4.3.4 минимум.

Что же, если хочешь &#8212; получай.

### Update тестового сервера

Естественно, что играюсь с разными системами я на тестовом сервере, который был скопирован с моего боевого сервера (т.е. да, там до сих пор стоит PHP 4.3.3) и обновляться не страшно.

Добавляем репозиторий Remi:

{% highlight bash %}
$ rpm -ihv http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
{% endhighlight %}

Не забудьте включить его в /etc/yum.repos.d/remi.repo

Обновляемся:

{% highlight bash %}
$ yum update
{% endhighlight %}

И, не буду долго разглагольствовать. Что мне пришлось пофиксить:

**PHP**

`/etc/php-fpm.d/www.conf`

{% highlight bash %}
listen.owner = nginx
listen.group = nginx
{% endhighlight %}

раскомментировать эти две строчки и прописать значения - пользователя из-под которого работает

**Nginx**

Так же сбросились права на папку `/var/lib/php/session`

{% highlight bash %}
$ cd /var/lib/php
$ chown nginx:nginx session
{% endhighlight %}

**Mysqld**

`/etc/my.cnf`

Новому Mysql не понравилось это: `default-character-set=utf8`. Просто закомментировал эту строчку

После рестарта `php-fpm` и `mysqld` все заработало нормально.

### ImageCMS &#8212; итог

После обновления я закончил установку и теперь приступлю к тестированию данной CMS.

Минусы:

* Отсутствие нормальной документации по установке на CentOS+Nginx+php-fpm.

Плюсы:

* Данная CMS напомнила мне про необходимость обновления core пакетов веб-сервера.
* Так же, я научился правильно создавать пользователей в mysql, но это к тексту не относится.

Материалы по теме:

* <a href="http://www.imagecms.net/" target="_blank">Официальный сайт</a>
* <a href="http://www.nginxtips.ru/znakomstvo-s-imagecms/" target="_blank">Статья взята с сайта</a>

---
layout: post
title: HTTPS в Nginx с сертификатом от Let's Encrypt
excerpt: "Прикручиваем https и перевыпуск сертифката"
permalink: /https-in-nginx-using-lets-encrypt/
tags:
  - Nginx
  - HTTPS
  - Letsencrypt
date: 2016-06-23T18:38:40+03:00
---

{% include _toc.html %}

<br>
<img src="https://farm8.staticflickr.com/7215/27761855362_84460bbf5b_o.png">
<br>
<br>


<a href="https://letsencrypt.org/" target="_blank">Let's Encrypt</a> это новый Центр сертификации (CA) который предоставляет простой способ для получения и установки бесплатных TLS/SSL сертификатов, позволяя включить HTTPS шифрование на веб серверах.

##Предварительные требования

Перед тем как начать вам потребуется несколько вещей.

* Виртуальный или выделенный сервер с установленной Debian based системой, например Ubuntu (не ниже 14.04).
* Привилегированный доступ т.е. учетная запись root или возможность использовать sudo без ограничений.
* Вы должны быть владельцем домена, для которого выпускаете сертификат и иметь возможность им управлять.

> Приобрести доменное имя можно, например, <a href="https://www.webnames.ru/domains/check?ref_id=189029" target="_blank">здесь</a>.

* <b>A</b> запись домена должна вести на ваш сервер.

##Установка клиента Let's Encrypt

Во-первых нужно установить программное обеспечение `letsencrypt`. На данный момент лучший способ это сделать это склонировать официальный git репозиторий на Github. Надеемся в будущем будет доступна адекватная установка через пакетные менеджеры (такие как apt/dpkg и yum/rpm).

####Установка необходимых зависимостей

{% highlight bash %}
$ sudo apt-get update && sudo apt-get -y install git bc
{% endhighlight %}

####Клонирование репозитория

{% highlight bash %}
$ sudo git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
{% endhighlight %}

После выполнения этой команды у нас должна появится рабочая версия ПО letsencrypt в каталоге `/opt/letsencrypt`

##Получение сертификата

Let's Encrypt предоставляет разные способы получения сертификата. Для `Apache` например имеется модуль, который "делает все сам", для `Nginx` такого плагина нет, поэтому мы будем только получать сертификат, а настраивать его самостоятельно. Для получения сертификата мы будем использовать функцию `Webroot` доступную в Let's Encrypt.

####Использование Webroot

Плагин `Webroot` размещает специальный файл в каталоге `/.well-known` внутри вашего document root.

> Document root - это полный путь до каталога, в котором располагаются ваши файлы сайта. В большинстве случаев это `/var/www/mysite`.

Именно этот файл будет проверяться системой Let's Encrypt во время валидации при получении сертификата. В зависимости от вашей конфигурации, может понадобиться разрешить доступ к каталогу `/.well-known`.

Если вы еще не установили Nginx, сейчас самое время. Сделать это можно командой:

{% highlight bash %}
$ sudo apt-get install nginx
{% endhighlight %}

Чтобы убедиться что у системы Let's Encrypt будет доступ к каталогу, добавим в дефолтный конфиг `/etc/nginx/sites-available/default` следующие строки внутри блока `server`:

{% highlight bash %}
location ~ /.well-known {
  allow all;
}
{% endhighlight %}

По дефолту в Nginx установлен Document root - `/usr/share/nginx/html`, можете проверить это в конфиге во избежании несоотвтетствий, после чего можно сохранить конфиг и выполнить релоад конфигурации Nginx.

{% highlight bash %}
$ sudo nginx -s reload
{% endhighlight %}


Когда мы знаем `webroot-path`, можем запросить SSL сертификат. В команде для получения сертификата мы используем ключ `-d` чтобы указать список доменных имен, если вам нужен сертификат не только на основной домен но и на поддомены, будьте уверены что включили все необходимые доменные имена.

> Важное замечание, Let's Encrypt не выдают, так называемые, wildcard сертификаты. Поэтому нужно внимательно отнеститесь к флагу `-d`.

Будьте внимательны при выполнении команды, проверьте что `webroot-path` и доменные имена указаны верно.

{% highlight bash %}
$ cd /opt/letsencrypt
$ ./letsencrypt-auto certonly -a webroot --webroot-path=/usr/share/nginx/html -d 'example.com,www.example.com'
{% endhighlight %}

После запуска `letsencrypt` установит и сконфигурирует некоторые программы, по большей части на Python, а потом запросит дополнительную информацию для генерации сертфикат, обычно это e-mail администратора:

<br>
<img src="https://farm8.staticflickr.com/7315/27786618061_4b14f8c984_o.png">
<br>
<br>

И пользовательское соглашение:

<br>
<img src="https://farm8.staticflickr.com/7402/27862249725_cbb63caf85_o.png">
<br>
<br>

Если все прошло как надо, то вы увидите что-то вроде:

{% highlight bash %}
IMPORTANT NOTES:
 - If you lose your account credentials, you can recover through
   e-mails sent to sammy@digitalocean.com
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/example.com/fullchain.pem. Your
   cert will expire on 2016-03-15. To obtain a new version of the
   certificate in the future, simply run Let's Encrypt again.
 - Your account credentials have been saved in your Let's Encrypt
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Let's
   Encrypt so making regular backups of this folder is ideal.
 - If like Let's Encrypt, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
{% endhighlight %}

####Файлы сертификата

После успешного получения сертификата вам будут доступны следующие PEM-encoded файлы:

* cert.pem: Сертификат домена
* chain.pem: Let's Encrypt chain сертификат
* fullchain.pem: слитые cert.pem и chain.pem
* privkey.pem: Приватный ключ вашего сертификата

Важно знать куда сохраняются данные файлы, так как мы будем настраивать Nginx. Сами файлы складываются в каталог `/etc/letsencrypt/archive`. Однако, Let's Encrypt создает символические ссылки на них вида `/etc/letsencrypt/live/your_domain_name`. Таким образом ссылки всегда будут указывать на самые актуальные сертификаты.

####Генерация группы Диффи — Хеллмана

Для повышения градуса безопасности нам нужно сгенерировать группу Диффи — Хеллмана (Diffie-Hellman Group), для этого используем команду:

{% highlight bash %}
$ sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
{% endhighlight %}

Это может занять какое-то время, но по завершении команды вы будете иметь сильную ДХ группу по пути `/etc/ssl/certs/dhparam.pem`.

##Настройка TLS/SSL в Nginx

Теперь когда у нас есть SSL сертификат, снова пойдем в конфиг Nginx и изменим настройки.

{% highlight bash %}
$ sudo nano /etc/nginx/sites-available/default
{% endhighlight %}

Найдем следующие строки внутри блока `server`:

{% highlight bash %}
listen 80 default_server;
listen [::]:80 default_server ipv6only=on;
{% endhighlight %}

И заменим их на:

{% highlight bash %}
listen 443 ssl;

server_name example.com www.example.com;

ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
{% endhighlight %}

Это собственно и включает шифрование соединений с помощью сертификатов, но для большей безопасности нужно также добавить следующие параметры:

{% highlight bash %}
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_stapling on;
ssl_stapling_verify on;
add_header Strict-Transport-Security max-age=15768000;
{% endhighlight %}

Также перед нашим блоком `server` использующим SSL, добавим еще один блок `server`, который будет перенаправлять все обычные, не зашифрованные запросы на SSL:

{% highlight bash %}
server {
  listen 80;
  server_name example.com www.example.com;
  return 301 https://$host$request_uri;
}
{% endhighlight %}

Сохраняем, выходим и применяем нашу конфигурацию.

{% highlight bash %}
sudo nginx -s reload
{% endhighlight %}

Теперь все на своих местах. Можем проверить уровень нашей безопасности на сайт SSL Labs (вместо example.com нужно подставить свое доменное имя):

{% highlight bash %}
https://www.ssllabs.com/ssltest/analyze.html?d=example.com
{% endhighlight %}

В отчете должна светиться оценка - <b>A+</b>.

##Автообновление сертифката

Сертификаты Let’s Encrypt действительны только в течение 90 дней, это одна из политик, также направленная на обеспечение безопасности. Чтобы обновить, или правильнее сказать, перевыпустить сертификат, нужно выполнить некоторые действия, похожие на получение сертификата.
<br />
На самом деле `letsencrypt` сделает все сам, нужно только запустить команду:

{% highlight bash %}
$ /opt/letsencrypt/letsencrypt-auto renew
{% endhighlight %}

Чтобы не забыть про перевыпуск сертификата, нужно автоматизировать запуск данной команды, для этого воспользуемся cron'ом.

{% highlight bash %}
$ sudo crontab -e
{% endhighlight %}

Добавим следующие строки:

{% highlight bash %}
30 2 * * 1 /opt/letsencrypt/letsencrypt-auto renew >> /var/log/le-renew.log
35 2 * * 1 /etc/init.d/nginx reload
{% endhighlight %}

Сохраняем файл и выходим, после этого команда будет выполняться каждый понедельник в 2.30 ночи, после чего в 2.35 будет применяться конфигурация Nginx.

##Обновление клиента Let’s Encrypt

Если для установки вы использовали клонирование репозитория то обновление сводится к выкачиванию изменений из репозитория. Это можно сделать с помощью команд:

{% highlight bash %}
$ cd /opt/letsencrypt
$ sudo git pull
{% endhighlight %}

##Повышаем градус безопасности

В принципе на этом можно остановиться, у нас уже есть шифрование на сайте. Однако для более полной безопасности нашего приложения стоит установить некоторые заголовки:

{% highlight bash %}
resolver            8.8.8.8;

add_header          X-Xss-Protection "1";
add_header          X-Frame-Options SAMEORIGIN;
add_header          X-Content-Type-Options nosniff;
add_header          Strict-Transport-Security "max-age=31557600";

# Read about this before including!
add_header          Content-Security-Policy "default-src 'self' googleapis.com";
{% endhighlight %}

Проверить заголовки можно <a href="https://securityheaders.io/" target="_blank">тут</a>.

###Заключение

Данный метод был протестирован и применен мной на нескольких проектах, на таких операционных системах как Debian, Ubuntu, Centos. Например, теперь мы шифруем все в магазине беспроводного оборудования - <a href="https://www.isbis.ru" target="_blank">https://www.isbis.ru</a>. Чтобы разобраться в вопросе я перечитал много всего, но наиболее полезными оказались следующие статьи:

* <a href="https://blog.benroux.me/production-https-rails-app-using-nginx-and-lets-encrypt/" target="_blank">Setting Up Rails Over HTTPS Using Nginx and Let's Encrypt</a>
* <a href="https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04" target="_blank">How To Secure Nginx with Let's Encrypt on Ubuntu 14.04</a>








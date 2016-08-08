---
layout: post
title: Адекватный вывод команды nginx -V
date: '2014-06-26 07:59:55'
permalink: /best-way-for-search-included-modules-in-nginx/
redirect_from: /adiekvatnyi-vyvod-komandy-nginx-v/
excerpt: ""
tags:
  - Nginx
  - Linux
---

В nginx есть несколько функций, например:

{% highlight bash %}
nginx -t
{% endhighlight %}

Проверит конфиги на правильность и скажет где ошибка, что очень удобно, ведь не приходится релоадить или перезапускать сервер, да и команда короткая. Так же можно посмотреть версию устанновленного nginx:

{% highlight bash %}
nginx -v
{% endhighlight %}

Еще есть ключ (-V), с которым команда nginx выводит список всех модулей, которые включены в состав пакета. И вот, при установке из разных репозиториев список этих модулей может варьироваться. Но когда вы захотите найти что-то в этом списке, то обнаружите, что вывод данной команды нельзя отфильтровать командой grep. Многие просто внимательно читают вывод и находят глазами, но это не мой путь.
В один прекрасный день, когда в очередной раз потребовалось проверить в каких же репозиториях Nginx поставляется с модулем geoip, я докопался до следующего:

{% highlight bash %}
# 2>&1 nginx -V | tr -- - '\n' | grep --color geoip
{% endhighlight %}

Вывод команды:

{% highlight bash %}
http_geoip_module
{% endhighlight %}

Такая команда подходит если вам нужно что-то отфильтровать, полный вывод же, будет не очень удобочитаемым. Дальнейшие исследования привели к следующему:

{% highlight bash %}
# A=`nginx -V 2>&1`;B=`echo $A|sed 's/ --/# --/g'|tr '#' '\n'|sed -n '/^ --/p'|sort`;printf "$A"|head -2;printf "configure arguments:\n$B\n"
{% endhighlight %}

В данном случае вывод будет такой:
{% highlight bash %}
nginx version: nginx/1.2.1
TLS SNI support enabled
configure arguments:
 --add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-auth-pam
 --add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-dav-ext-module
 --add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-echo
 --add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-upstream-fair
 --conf-path=/etc/nginx/nginx.conf
 --error-log-path=/var/log/nginx/error.log
 --http-client-body-temp-path=/var/lib/nginx/body
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi
 --http-log-path=/var/log/nginx/access.log
 --http-proxy-temp-path=/var/lib/nginx/proxy
 --http-scgi-temp-path=/var/lib/nginx/scgi
 --http-uwsgi-temp-path=/var/lib/nginx/uwsgi
 --lock-path=/var/lock/nginx.lock
 --pid-path=/var/run/nginx.pid
 --prefix=/etc/nginx
 --with-debug
 --with-http_addition_module
 --with-http_dav_module
 --with-http_geoip_module
 --with-http_gzip_static_module
 --with-http_image_filter_module
 --with-http_realip_module
 --with-http_ssl_module
 --with-http_stub_status_module
 --with-http_sub_module
 --with-http_xslt_module
 --with-ipv6
 --with-mail
 --with-mail_ssl_module
 --with-md5=/usr/include/openssl
 --with-pcre-jit
 --with-sha1=/usr/include/openssl
{% endhighlight %}

Вывод классный! Но вот каждый раз, когда нужно проверить список модулей, такую команду не введешь. Так что я продолжил поиски и пришел к такому варианту:
{% highlight bash %}
# 2>&1 nginx -V | xargs -n1
{% endhighlight %}

Который дает вывод:

{% highlight bash %}
nginx
version:
nginx/1.2.1
TLS
SNI
support
enabled
configure
arguments:
--prefix=/etc/nginx
--conf-path=/etc/nginx/nginx.conf
--error-log-path=/var/log/nginx/error.log
--http-client-body-temp-path=/var/lib/nginx/body
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi
--http-log-path=/var/log/nginx/access.log
--http-proxy-temp-path=/var/lib/nginx/proxy
--http-scgi-temp-path=/var/lib/nginx/scgi
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi
--lock-path=/var/lock/nginx.lock
--pid-path=/var/run/nginx.pid
--with-pcre-jit
--with-debug
--with-http_addition_module
--with-http_dav_module
--with-http_geoip_module
--with-http_gzip_static_module
--with-http_image_filter_module
--with-http_realip_module
--with-http_stub_status_module
--with-http_ssl_module
--with-http_sub_module
--with-http_xslt_module
--with-ipv6
--with-sha1=/usr/include/openssl
--with-md5=/usr/include/openssl
--with-mail
--with-mail_ssl_module
--add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-auth-pam
--add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-echo
--add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-upstream-fair
--add-module=/tmp/buildd/nginx-1.2.1/debian/modules/nginx-dav-ext-module
{% endhighlight %}

Он короткий, его можно легко запомнить, и он фильтруется при помощи grep.

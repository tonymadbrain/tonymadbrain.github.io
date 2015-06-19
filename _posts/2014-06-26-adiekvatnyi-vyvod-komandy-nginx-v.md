---
layout: post
title: Адекватный вывод команды nginx -V
date: '2014-06-26 07:59:55'
---

В nginx есть несколько функций, например:
<pre> 
nginx -t 
</pre>
Проверит конфиги на правильность и скажет где ошибка, что очень удобно, ведь не приходится релоадить или перезапускать сервер, да и команда короткая. 
Так же можно посмотреть версию устанновленного nginx:
<pre>
nginx -v
</pre>
Еще есть ключ (-V), с которым команда nginx выводит список всех модулей, которые включены в состав пакета. И вот, при установке из разных репозиториев список этих модулей может варьироваться. Но когда вы захотите найти что-то в этом списке, то обнаружите, что вывод данной команды нельзя отфильтровать командой grep. Многие просто внимательно читают вывод и находят глазами, но это не мой путь. 
В один прекрасный день, когда в очередной раз потребовалось проверить в каких же репозиториях Nginx поставляется с модулем geoip, я докопался до следующего:
<pre>
root@proxmox:# 2>&1 nginx -V | tr -- - '\n' | grep --color geoip
http_geoip_module
root@proxmox:#
</pre>
Такая команда подходит если вам нужно что-то отфильтровать, полный вывод же, будет не очень удобочитаемым. 
Дальнейшие исследования привели к следующему:
<pre>
root@proxmox:# A=`nginx -V 2>&1`;B=`echo $A|sed 's/ --/# --/g'|tr '#' '\n'|sed -n '/^ --/p'|sort`;printf "$A"|head -2;printf "configure arguments:\n$B\n"
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
root@proxmox:#
</pre>
Вывод классный! Но вот каждый раз, когда нужно проверить список модулей, такую команду не введешь. 
Так что я продолжил поиски и пришел к такому варианту:
<pre>
root@proxmox:# 2>&1 nginx -V | xargs -n1
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
root@proxmox:#
</pre>
Он короткий, его можно легко запомнить, и он фильтруется при помощи grep. 

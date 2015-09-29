---
layout: post
title: "Mariadb не, использовать Mysql"
permalink: /2015-05-20-no-mariadb-just-mysql/
date: 2015-05-20T00:12:00+03:00
tags:
  - Mariadb
  - Mysql
  - SA
---

Изначально планировалось поставить запятую после Mariadb. Собственно сабж в том, что я хотел перевести свой сервер с парой rails приложений c mysql 5.1 на mariadb 10, но не тут то было. Я столкнулся со странной магией и из-за отсутсвия времени отступил перед лицом проблемы.

<br>
<img src="https://farm1.staticflickr.com/566/21467225109_17f981a0d5_o.png">
<br>

В начале на сервере с Centos 6.6 работали redmine, gitlab и несколько простых парсеров на ruby, которые с базой не общаются (пока). Стояла версия ```mysql-server-5.1.73-3.el6_5.x86_64```. Было произведено "легкое" обновление до ```mysql-community-server-5.6.24-3.el6.x86_64``` по <a href="https://www.digitalocean.com/community/tutorials/how-to-install-mysql-5-6-from-official-yum-repositories" target="_blank">инструкции с DO.</a>. Затем был произведен полный backup утилитой xtrabackup из <a href="https://www.percona.com/doc/percona-server/5.5/installation/yum_repo.html" target="_blank">репозитория Percona</a>. И наконец было выполнено обновление до версии MariaDB-server-10 (<a href="https://mariadb.com/kb/en/mariadb/yum/" target="_blank">ман</a>).
Естественно на время обновлений сервисы отключались. И вот, готовый к неожиданностям я начал их запускать и столкнулся с ошибкой:

{% highlight bash %}
Incorrect MySQL client library version! This gem was compiled for 5.1.73 but the client library is 5.3.12-MariaDB.
{% endhighlight %}

Гугления привели к <a href="https://github.com/brianmario/mysql2/issues/506" target="_blank">решению</a>:

{% highlight bash %}
$ gem uninstall mysql2
$ bundle config build.mysql2 --with-mysql-config=/usr/bin/mysql_config
$ bundle install
{% endhighlight %}

Сперва я опробовал его на redmine, и оно сработало, redmine принял новую версию базы данных как родную. Однако с gitlab это не прокатило...

Я бился пару дней, но в результате решил не тратить больше времени и откатился до mysql 5.6, чтобы gitlab работал. Для меня осталось загадкой, почему переустановка гема с необходимым параметром для одного приложения сработала нормально, а для другого нет. Версия гема ведь одинаковая. В печали я открыл <a href="https://github.com/gitlabhq/gitlabhq/issues/9313" target="_blank">issue</a> в репозитории gitlabhq, но судя по отсутсвию активности, решение если и будет то не скоро. Эта статья задумывалась как мануал по переходу с mysql 5 на mariadb 10, но в итоге одно разочарование.

---
layout: post
title:  Мелкие заметки из redmine
excerpt: "Заметки из redmine"
permalink: /small_notes_from_redmine/
tags:
  - Centos
  - Mysql
date: 2016-10-23T14:45:37+03:00
---

> У меня в redmine лежат заметки, к которым не обращаюсь, но выглядят они полезными, поэтому перенесу их сюда, как бы в архив.

# Смена hostname в CentOS

Открываем файл `/etc/sysconfig/network` и редактируем

{% highlight bash %}
HOSTNAME="example.com"
{% endhighlight %}

Далее выполняем команду:

{% highlight bash %}
$ hostname example.com
{% endhighlight %}

Потом открываем файл `/etc/hosts` и редактируем или добавляем если нет такой строки:

{% highlight bash %}
127.0.0.1 example.com localhost localhost.localdomain
{% endhighlight %}

# Смена часового пояса в CentOS

{% highlight bash %}
$ cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
{% endhighlight %}

# Работа со временем в CentOS

Для синхронизации времени нужно установить пакет ntp

{% highlight bash %}
$ yum y install ntp
{% endhighlight %}

Для выполнения синхронизации в настоящий момент:

{% highlight bash %}
$ ntpdate pool.ntp.org
{% endhighlight %}

Зимнее московское время отображается не верно? Обновите пакет tzdata!

{% highlight bash %}
$ yum upgrade tzdata
{% endhighlight %}

Открываем конфиг:

{% highlight bash %}
$ vim /etc/sysconfig/ntpd
{% endhighlight %}

Корректируем там:

{% highlight bash %}
SYNC_HWCLOCK=yes
{% endhighlight %}

А также изменяем (-L чтобы не слушать сеть вообще):

{% highlight bash %}
OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid -L"
{% endhighlight %}

Синхронизируем время:

{% highlight bash %}
$ /usr/sbin/ntpdate 0.rhel.pool.ntp.org europe.pool.ntp.org
{% endhighlight %}

Добавляем в автозапуск:

{% highlight bash %}
$ /sbin/chkconfig ntpd on
{% endhighlight %}

Запускаем:

{% highlight bash %}
$ /etc/init.d/ntpd start
{% endhighlight %}

Но иногда ntpd глючит и получается большие отставания:

{% highlight bash %}
$ sntp time.nist.gov
2010 Feb 19 16:33:10.653 + 79.089 +/ 0.152 secs
{% endhighlight %}

Тогда надо делать следующее:

{% highlight bash %}
$ /etc/init.d/ntpd stop
$ /usr/sbin/ntpdate 0.rhel.pool.ntp.org europe.pool.ntp.org
$ /etc/init.d/ntpd start
{% endhighlight %}

Теперь все ок:

{% highlight bash %}
$ sntp time.nist.gov
2010 Feb 19 16:33:25.111 - 0.009 +/- 0.151 secs
{% endhighlight %}

Время железа и его синхронизация с системным

{% highlight bash %}
$ hwclock --show
$ hwclock --systohc
{% endhighlight %}

# Создание новой базы в MySQL

{% highlight bash %}
> CREATE DATABASE db_name CHARACTER SET utf8 COLLATE utf8_general_ci;
> use db_name;
> GRANT SELECT,LOCK TABLES,CREATE TEMPORARY TABLES,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX ON db_name.* TO 'db_user'@'localhost' identified by 'password';
> flush privileges;
{% endhighlight %}

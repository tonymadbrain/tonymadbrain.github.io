---
layout: post
title: Мониторинг PHP-FPM через FastCGI в Zabbix
permalink: /fcgi_monitoring_with_zabbix/
excerpt: ""
tags:
  - Zabbix
  - Php-fpm
  - SA
date: 2016-11-23T21:34:01+03:00
---

Решил у нас в <a href="http://imhonet.ru" target="_blank">Имхонете</a> сделать мониторинг PHP-FPM, чтобы все было как у нормальных пацанов. Советы в интернете сводятся к тому, чтобы включить статус и проксировать запросы в него через Nginx. Но я считаю, что это как ездить на метро с пересадкой, при условии что пешком дойти ближе и быстрее, поэтому сделал все сам.

{% include _toc.html %}

## PHP-FPM

В самом PHP-FPM нам нужно только включить страницу статуса и ответ на пинг запрос. Для этого в конфиг пула (по умолчанию это `/etc/php/fpm/pool.d/www.conf`) нужно добавить следующие строки:

{% highlight bash %}
pm.status_path = /status
ping.path = /ping
{% endhighlight %}

И перезагрузить демон:

{% highlight bash %}
$ /etc/init.d/php-fpm restart
{% endhighlight %}

## Zabbix

### Cкрипт

Первую реализацию я написал на Bash, сначала напишу его разбор а потом приведу целиком.

Первой строкой указываем чем необходимо выполнять скрипт:

{% highlight bash %}
#!/usr/bin/env bash
{% endhighlight %}

Записываем в переменную подсказку по использованию скрипта:

{% highlight bash %}
help="Usage: fcgi <ip or dns for check> <port> <check type, maybe ping or status> <parameter, only for status>\nExample: fcgi 127.0.0.1 3000 ping"
{% endhighlight %}

В скрипте есть три функции `ping` - для простой проверки, `status` - для получения пар параметр:значение и `status_clear` - для получения статуса без парсинга:

{% highlight bash %}
function ping {
  SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect $address:$port
}

function status {
  SCRIPT_NAME=/status SCRIPT_FILENAME=/status REQUEST_METHOD=GET cgi-fcgi -bind -connect $address:$port | sed -n "$1p;$1q" | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

function status_clear {
  SCRIPT_NAME=/status SCRIPT_FILENAME=/status REQUEST_METHOD=GET cgi-fcgi -bind -connect $address:$port
}
{% endhighlight %}

После объявления функций сетим переменные:

{% highlight bash %}
address=$1
port=$2
parameter=$4
{% endhighlight %}

Ну и дальше основная обработка, в зависимости от типа проверки и параметров вызываются функции и каким-либо образом обрабатываются:

{% highlight bash %}
case "$3" in
  "ping" )
    ping | tail -n1
  ;;
  "status" )
    case "$parameter" in
      "pool" )
        status_clear | sed -n '6p;6q' | awk '{print $2}'
      ;;
      "version" )
        status_clear | sed -n '1p;1q' | awk -F/ '{print $2}'
      ;;
      "process_manager" )
        status 7
      ;;
      "accepted_conn" )
        status 10
      ;;
      "listen_queue" )
        status 11
      ;;
      "max_listen_queue" )
        status 12
      ;;
      "listen_queue_len" )
        status 13
      ;;
      "idle_processes" )
        status 14
      ;;
      "active_processes" )
        status 15
      ;;
      "total_processes" )
        status 16
      ;;
      "max_active_processes" )
        status 17
      ;;
      "max_children_reached" )
        status 18
      ;;
      "slow_requests" )
        status 19
      ;;
      "latency" )
        time=$(date +%s%N)
        ping >> /dev/null
        echo "$(( ($(date +%s%N)-$time) / 1000000 ))"
      ;;
      "all" )
        status_clear
      ;;
      * )
        echo -e "Bad command!\n$help"
      ;;
    esac
  ;;
  * )
  echo -e "Bad command $3!\n$help"
  ;;
esac
{% endhighlight %}

Скрипт полностью можно скачать <a href="http://s.doam.ru/blog/fcgi_monitoring_with_zabbix/fcgi.txt" target="_blank">здесь</a>. Чтобы использвать его во внешних проверках нужно:

1. Переместить его в каталог `/usr/lib/zabbix/externalscripts/`
2. Переименовать `fcgi.txt` -> `fcgi`
3. Сделать исполняемым `chmod +x fcgi`
4. Установить пользователя `chown -R zabbix:zabbix fcgi`

Также для работы скрипта должна быть установлена программа `cgi-fcgi` в Debian пакет для установки называется `fcgiwrap`.

### Шаблон

Сам шаблон можно скачать <a href="http://s.doam.ru/blog/fcgi_monitoring_with_zabbix/zbx_php-fpm_template.xml" target="_blank">тут</a>. После импорта его необходимо подключить к узлам на которых крутится PHP-FPM. Для запросов используются две переменные: встроенная `HOST.CONN` и макрос `FPM_PORT` добавленный мной, по дефолту там стоит значение `3000`.

В шаблоне несколько итемов, 2 триггера, графики и даже скрины, все как положено.

## Заключение

Таким образом я решил задачу мониторинга необходимых нам параметров, но эту реализация считаю недостаточной. В дальнейшем хочу переписать его на <a href="https://golang.org/" target="_blank">golang</a> c использованием вот <a href="https://github.com/tomasen/fcgi_client" target="_blank">этой библиотеки</a>. Так как это внешняя проверка она должна работать быстро, а `bash` не подходит по этому параметру. Если у вас есть рекомендации или доработки пишите мне на почту или в Twitter.

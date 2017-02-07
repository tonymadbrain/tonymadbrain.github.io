---
layout: post
title: Скрипты внешних проверок Nginx и PHP-FPM для Zabbix
excerpt: Заопенсорсил свой "говнокод" на Golang.
permalink: /open_source_some_zabbix_scripts/
tags:
  - Zabbix
  - Golang
  - DevOps
image:
  graph: https://farm1.staticflickr.com/458/32382332380_9e8f620d42_o.jpg
date: 2017-02-07T11:45:03+03:00
---

<figure>
  <img src="https://farm1.staticflickr.com/458/32382332380_9e8f620d42_o.jpg"></a>
</figure>

<a href="http://doam.ru/fcgi_monitoring_with_zabbix/">Вот здесь</a> я писал про мониторинг PHP-FPM в Zabbix и в заключении указал что собираюсь переписать скрипт на Golang. Как и обещал, я это сделал, правда, будучи новичком в этом языке, предполагаю что там говнокодец. Помимо мониторинга PHP-FPM также сделал скрипт для чека Nginx. Оба скрипта я заопенсорсил, выложив на Github:

* <a href="https://github.com/tonymadbrain/fcgi_stat_getter">PHP-FPM</a>
* <a href="https://github.com/tonymadbrain/nginx_stat_getter">Nginx</a>

А также на share.zabbix.com:

* <a href="https://share.zabbix.com/cat-app/web-servers/fcgi-stat-getter-monitor-php-fpm-without-nginx-proxy">PHP-FPM</a>
* <a href="https://share.zabbix.com/cat-app/web-servers/nginx-stat-getter-simple-check-for-nginx-stats">Nginx</a>

В обоих шаблонах присутствуют графики и даже скрины. Скомпилированный бинарник Golang отрабатывает почти также быстро как и проверки самого Zabbix. Код тривиальный и может быть доработан с минимальными знаниями.

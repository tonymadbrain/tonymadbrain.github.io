---
layout: post
title: Блокируем/разрешаем доступ к сайту по IP
date: '2014-08-25 11:12:32'
excerpt: ""
permalink: /how-to-block-access-to-site-with-ip/
redirect_from: /blokiruiemrazrieshaiem-dostup-k-saitu-po-ip/
tags:
  - Nginx
  - Ip
---

<br>
<img src="https://farm1.staticflickr.com/770/21663180281_2052eb289c_o.jpg">
<br>
<br>

Если вам нужно забанить кого-нибудь, либо, как в моем случае, разрешить доступ только определенным клиентам, в случае с `Nginx` следует использовать следующую конструкцию:

{% highlight bash %}
allow 192.168.0.0/24; # разрешить внутренней подсети
allow xx.xxx.xx.xxx;  # разрешить внешнему адресу
deny    all;          # запретить все
{% endhighlight %}

Во-первых, так можно писать в любой `lcoation`, чтобы закрыть только часть сайта. Во-вторых, сначала должны следовать разрешающие правила, а потом запрещающие, т.е. **allow xxx.xxx.xxx.xxx;** после правила **deny all;** обрабатываеться уже не будет.

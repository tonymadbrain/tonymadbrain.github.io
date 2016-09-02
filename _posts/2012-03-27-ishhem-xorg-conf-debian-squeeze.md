---
title: Ищем xorg.conf debian squeeze
layout: post
permalink: /finding_xorg-conf_in_debian_squeeze/
redirect_from: /ishhem-xorg-conf-debian-squeeze/
excerpt: ""
tags:
  - Debian
  - Xorg.conf
  - Root
---

При переходе на squeeze, либо при первой установке и попытке настроить свой debian, скорее всего вы "нагуглили" много информации по замечательному файлу конфигурации - xorg.conf, однако найти его в каталоге `/etc/X11` не смогли. Можете и не искать, начиная со squeeze его там не будет пока сами не запихнем. Делается все легким движением руки:

Переходим в режим консоли `ctrl+alt+f1`, останавливаем иксы и возвращаем xorg.conf на место следующими командами:

{% highlight bash %}
$ Xorg -configure
$ cp -pb $HOME/xorg.conf.new /etc/X11/xorg.conf
{% endhighlight %}

Потом можно отредактировать xorg.conf как Вам нужно и пробовать запустить X-ы, если они не стартанули значит вы допустили ошибку (Будьте внимательны, одна опечатка в xorg.conf приводит к НЕ запуску X-сервера).

---
title: Правим цвет приглашения в squeeze
layout: post
permalink: /pravim-tsvet-priglasheniya-v-squeeze/
slider_image:
  -
categories:
  - Debian
tags:
  - Bash
  - Bashrc
  - Debian
  - Colors
---
Чтобы случайно не натворить чего-нибудь на удаленном серваке по ssh или telnet, я решил изменить цвет приглашения в консоли, чтобы видеть на своем буке я или на удаленке. Нашел много примеров, однако в squeeze они не сработали. В результате всех "ковыряний" и советов гуру пришел к такому методу:

В папке нашего пользователя лежит файл .bashrc все изменения в нем применяются только к данному пользователю, а здесь /etc/bash.bashrc лежит общий конфиг и применяется он когда мы логинимся под рутом. Итак в .bashrc находим строчку примерно такого плана

{% highlight bash %}
PS1='${debian_chroot:+($debian_chroot)}[33[0;40;4;32m]u@h[33[00m]:[33[01;34m]w[33[00m]$ '
{% endhighlight %}

и заменяем на

{% highlight bash %}
PS1='[33[01;32m]u@[33[01;36m]h$[33[00m] '
{% endhighlight %}

Цифра перед буквой m означает цвет, они бывают:

{% highlight bash %}
Название цвета Текст Фон
Черный 30 40
Красный 31 41
Зеленый 32 42
Желтый 33 43
Синий 34 44
Маджента 35 45
Циановый 36 46
Белый 37 47
{% endhighlight %}

Если хотим изменить приглашение рута, то правим /etc/bash.bashrc, там проделываем примерно то же самое по аналогии.
Вот собственно и всё, а вот и мой скриншот:

<figure>
  <a href="http://res.cloudinary.com/doam-ru/image/upload/v1409070685/snimok_lhmrec.png"><img src="http://res.cloudinary.com/doam-ru/image/upload/v1409070685/snimok_lhmrec.png"></a>
</figure>

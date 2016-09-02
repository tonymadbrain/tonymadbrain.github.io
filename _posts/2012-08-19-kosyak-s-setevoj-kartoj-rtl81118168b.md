---
title: Косяк с сетевой картой rtl8111/8168B
layout: post
permalink: /problem_with_network_card_rtl81118168b/
redirect_from: /kosyak-s-setevoj-kartoj-rtl81118168b/
excerpt: "Обходим проблему с драйвером Realtek"
tags:
  - Debian
  - Ethernet
  - Rtl8168
  - Root
---

Взбрело мне в голову в очередной раз перезалить debian на стационаре (обычно я это делаю когда забиваю систему всякой фигней, после чего становиться невозможно в ней работать), и в очередной раз про косяк с сетевой картой, я вспомнил только после установки.

Проблема заключается в том, что с дровами, идущими в debian-squeeze по умолчанию сетевушку жутко плющит, она отправляет максимум 100 пакетов и дохнет, оживить её удается только ребутом. Когда первый раз столкнулся с таким раскладом, я нашел решение, однако все время забываю положить инструкцию и необходимые файлы куда-нибудь в доступное место. И вот сегодня пока стационар меееедленно качает необходимые пакеты, решил записать костыль в блог, чтобы потом не рыскать снова по интернетам и своему винту, чтобы найти все необходимое.
Итак, собственно исправление проблемы:
<br>
<br>
Загрузить пакеты:

{% highlight bash %}
$ apt-get install build-essential module-assistant kernel-package libncurses5 fakeroot make
$ apt-get install linux-headers-$(uname -r) modconf debhelper
{% endhighlight %}

Загрузить дрова от realtek:

<a href="http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false" target="_blank">www.realtek.com.tw</a>

Распаковать дрова в любую удобную папку, сделать файл autorun.sh исполняемым &#8212;

{% highlight bash %}
$ chmod +x autorun.sh
{% endhighlight %}

Запустить его &#8212;


{% highlight bash %}
$ ./autorun.sh
{% endhighlight %}
Всего-то, скажете Вы, но незнание этих мелочей выливается в большой геморрой.

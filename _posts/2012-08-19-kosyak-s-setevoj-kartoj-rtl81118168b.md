---
title: Косяк с сетевой картой rtl8111/8168B
author: madman
layout: post
permalink: /kosyak-s-setevoj-kartoj-rtl81118168b/
categories:
  - Debian
  - root
tags:
  - debian
  - eth0
  - rtl8168
---
Взбрело мне в голову в очередной раз перезалить debian на стационаре (обычно я это делаю когда забиваю систему всякой фигней, после чего становиться невозможно в ней работать), и в очередной раз про косяк с сетевой картой, я вспомнил только после установки. <img title="Read More..." src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" alt="" data-wp-more="" data-mce-resize="false" data-mce-placeholder="1" />

<!--more-->

Проблема заключается в том, что с дровами, идущими в debian-squeeze по умолчанию сетевушку жутко плющит, она отправляет максимум 100 пакетов и дохнет, оживить её удается только ребутом. Когда первый раз столкнулся с таким раскладом, я нашел решение, однако все время забываю положить инструкцию и необходимые файлы куда-нибудь в доступное место. И вот сегодня пока стационар меееедленно качает необходимые пакеты, решил записать костыль в блог, чтобы потом не рыскать снова по интернетам и своему винту, чтобы найти все необходимое.  
Итак, собственно исправление проблемы:  
Загрузить пакеты: 

<a class='spoiler-tgl' href='https://doam.ru/kosyak-s-setevoj-kartoj-rtl81118168b/#SID545_1_tgl' id='SID545_1_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID545_1' class='spoiler-body'>
  <p>
    apt-get install build-essential module-assistant kernel-package libncurses5 fakeroot make<br /> apt-get install linux-headers-$(uname -r) modconf debhelper
  </p>
</div>

Загрузить дрова от realtek:  
<a href="http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false" target="_blank">www.realtek.com.tw</a>  
Распаковать дрова в любую удобную папку, сделать файл autorun.sh исполняемым &#8212;

<a class='spoiler-tgl' href='https://doam.ru/kosyak-s-setevoj-kartoj-rtl81118168b/#SID545_2_tgl' id='SID545_2_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID545_2' class='spoiler-body'>
  <p>
    chmod +x autorun.sh
  </p>
</div>

Запустить его &#8212;

<a class='spoiler-tgl' href='https://doam.ru/kosyak-s-setevoj-kartoj-rtl81118168b/#SID545_3_tgl' id='SID545_3_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID545_3' class='spoiler-body'>
  <p>
    ./autorun.sh
  </p>
</div>

Всего-то, скажете Вы, но незнание этих мелочей выливается в большой геморрой.
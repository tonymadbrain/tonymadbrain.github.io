---
title: Ищем xorg.conf debian squeeze
author: madman
layout: post
permalink: /ishhem-xorg-conf-debian-squeeze/
slider_image:
  - 
categories:
  - Debian
  - root
tags:
  - debian
  - xorg.conf
---
При переходе на squeeze, либо при первой установке и попытке настроить свой debian, скорее всего вы &#171;нагуглили&#187; много информации по замечательному файлу конфигурации &#8212; xorg.conf, однако найти его в каталоге /etc/X11 не смогли. Можете и не искать, начиная со squeeze его там не будет пока сами не запихнем. Делается все легким движением руки:<! --more--> переходим в режим консоли ctrl+alt+f1, останавливаем иксы и возвращаем xorg.conf на место следующими командами:

<a class='spoiler-tgl' href='https://doam.ru/ishhem-xorg-conf-debian-squeeze/#SID407_1_tgl' id='SID407_1_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID407_1' class='spoiler-body'>
  <p>
    # Xorg -configure
  </p>
  
  <p>
    # cp -pb $HOME/xorg.conf.new /etc/X11/xorg.conf
  </p>
</div>

потом можно отредактировать xorg.conf как Вам нужно и пробовать запустить X-ы, если они не стартанули значит вы допустили ошибку (Будьте внимательны, одна опечатка в xorg.conf приводит к НЕ запуску X-сервера).

P.S. Если возникли вопросы, можете смело писать их в комментариях ниже. Если у Вас нет аккаунта Вконтакте, можете отправить письмо с вопросом по адресу mail@antonryabov.ru. Спасибо за внимание =);
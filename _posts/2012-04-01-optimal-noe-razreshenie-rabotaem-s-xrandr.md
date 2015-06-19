---
title: Оптимальное разрешение. Работаем с xrandr
layout: post
permalink: /optimal-noe-razreshenie-rabotaem-s-xrandr/
slider_image:
  - 
categories:
  - Debian
  - root
  - Soft
tags:
  - Debian
  - Xrandr
---
Столкнулся с проблемой: монитор поддерживает разрешение 1920&#215;1080 и с драйвером radeon работал нормально, но после того как я решил затестить драйвер radeonhd разрешение изменилось и выхлоп xrandr изменился на <! --more-->

<a class='spoiler-tgl' href='https://doam.ru/optimal-noe-razreshenie-rabotaem-s-xrandr/#SID413_1_tgl' id='SID413_1_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID413_1' class='spoiler-body'>
  <p>
    Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 1920 x 1920<br /> HDMI-0 disconnected (normal left inverted right x axis y axis)<br /> VGA-0 connected 1680&#215;1050+0+0 (normal left inverted right x axis y axis) 478mm x 269mm<br /> 1680&#215;1050 60.0*+<br /> 1280&#215;1024 75.0<br /> 1440&#215;900 75.0 59.9<br /> 1280&#215;960 60.0<br /> 1280&#215;800 59.8<br /> 1152&#215;864 75.0<br /> 1280&#215;720 60.0<br /> 1152&#215;720 60.0<br /> 1024&#215;768 75.0 70.1 60.0<br /> 832&#215;624 74.6<br /> 800&#215;600 72.2 75.0 60.3 56.2<br /> 640&#215;480 75.0 72.8 66.7 59.9<br /> 720&#215;400 70.1<br /> DVI-0 disconnected (normal left inverted right x axis y axis)
  </p>
</div>

Чтобы вручную установить правильно разрешение пришлось добавлять новый режим:

<a class='spoiler-tgl' href='https://doam.ru/optimal-noe-razreshenie-rabotaem-s-xrandr/#SID413_2_tgl' id='SID413_2_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID413_2' class='spoiler-body'>
  <p>
    xrandr &#8212;newmode &#171;1920&#215;1080&#8243; 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync<br /> xrandr &#8212;addmode VGA_1 &#171;1920&#215;1080&#8243;<br /> xrandr &#8212;output VGA_1 &#8212;mode 1920&#215;1080
  </p>
</div>

Однако это решение одноразовое, лично я вернулся обратно на драйвер radeon и не парюсь, но если Вам все-таки придется использовать такую конструкцию, то эти 3 строчки лучше закинуть в автозапуск ну или в скрипт, а уже скрипт в автозапуск =)  
Инструкция по работе с xrandr <a
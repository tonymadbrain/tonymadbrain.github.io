---
title: Оптимальное разрешение. Работаем с xrandr
layout: post
permalink: /optimal_resolution_working_with_xrandr/
redirect_from: /optimal-noe-razreshenie-rabotaem-s-xrandr/
excerpt: ""
tags:
  - Debian
  - Xrandr
  - Root
---

Столкнулся с проблемой: монитор поддерживает разрешение 1920x1080 и с драйвером radeon работал нормально, но после того как я решил затестить драйвер radeonhd разрешение изменилось и выхлоп xrandr изменился на

{% highlight bash %}
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 1920 x 1920
HDMI-0 disconnected (normal left inverted right x axis y axis)
VGA-0 connected 1680x1050+0+0 (normal left inverted right x axis y axis) 478mm x 269mm
1680x1050 60.0*+
1280x1024 75.0
1440x900 75.0 59.9
1280x960 60.0
1280x800 59.8
1152x864 75.0
1280x720 60.0
1152x720 60.0
1024x768 75.0 70.1 60.0
832x624 74.6
800x600 72.2 75.0 60.3 56.2
640x480 75.0 72.8 66.7 59.9
720x400 70.1
DVI-0 disconnected (normal left inverted right x axis y axis)
{% endhighlight %}

Чтобы вручную установить правильно разрешение пришлось добавлять новый режим:

{% highlight bash %}
xrandr -newmode "1920x1080" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
xrandr -addmode VGA_1 "1920x1080"
xrandr -output VGA_1 -mode 1920x1080
{% endhighlight %}

Однако это решение одноразовое, лично я вернулся обратно на драйвер radeon и не парюсь, но если Вам все-таки придется использовать такую конструкцию, то эти 3 строчки лучше закинуть в автозапуск ну или в скрипт, а уже скрипт в автозапуск =)

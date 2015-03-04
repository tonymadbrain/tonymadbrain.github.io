---
title: Рецепт приготовления debian на нетбуке
layout: post
permalink: /retsept-prigotovleniya-debian-na-netbuke/
slider_image:
  - 
categories:
  - Debian
  - root
  - Soft
tags:
  - conky
  - debian
  - linux
  - openbox
  - tint2
  - конфиги
---
<img class="alignright" title="debian-powered" src="http://doam.ru/wp-content/uploads/2012/03/debian-powered.png" alt="" width="180" height="180" />

На новой работе, я понял, что операционная система windows абсолютно неудобная и не функциональная в контексте задач моего рабочего поста. И перешел к более полному познанию linux. Наиболее привлекательной для меня является ос debian, её и решено было использовать на моем нетбуке samsung n150. За пару месяцев затачивания ос &#171;под себя&#187;, я умудрился несколько раз переустановить основную систему, зато это помогло довести процесс установки практически до автоматизма. Ниже будет представлен мой рецепт приготовления debian, с индивидуальным набором приправ =) <!--more-->

Итак, приступим. Debian полностью поддерживает все железо моего бука &#171;из коробки&#187;, поэтому париться с драйверами особо не придется. Загрузочную флешку я всегда создаю с помощью ultraiso, google поможет в случае возникновения вопросов.  
Установку основной системы я описывать не буду, скажу только, что лучше делать это с втыкнутым ethernet кабелем и сервером dhcp, так же советую использовать зеркало Яндекса. Так как windows мне все-таки нужен, для редких задач, под linux я выделил 120 гигабайт пространства на винчестере моего малыша samsung&#8217;a, 4 из них ушли под своп раздел (нет не много, я считаю, что swap раздел должен в два раза превышать объем оперативной памяти, и хоть пока в буке установлен 1 гигабайт, в дальнейшем я планирую заменить планку на 2 гиговую), 20 ушли под / &#8212; корень системы, а все оставшееся отдал на съедение разделу home.

Первым делом после запуска системы логинимся под рутом (надеюсь единственный раз) и редактируем файлик /etc/sudoers это можно сделать так же командой visudo. После строк

> \# User privilege specification  
> root ALL=(ALL) ALL

добавляем запись типа &#8212; user ALL=(ALL) NOPASSWD:ALL (user ваше имя пользователя конечно). После чего для получения прав суперпользователя нам не потребуется логиниться, а нужно будет всего лишь перед необходимой командой добавить &#8212; sudo, что означает выполнять от суперпользователя. Продолжаем, теперь отредактируем файл /etc/apt/sources.list в нем необходимо за комментировать строчку с cdrom (обычно первая), и добавить ftp репозиторий  
deb http://ftp.debian.org/debian/ squeeze main non-free contrib  
deb-src http://ftp.debian.org/debian/ squeeze main non-free contrib  
После этого выполнить  
sudo apt-get update  
И можно приступать к забойной закачке пакетов ^^)

<a class='spoiler-tgl' href='https://doam.ru/retsept-prigotovleniya-debian-na-netbuke/#SID368_1_tgl' id='SID368_1_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID368_1' class='spoiler-body'>
  <p>
    sudo apt-get install x-window-system<br /> sudo apt-get install openbox<br /> sudo apt-get install slim<br /> sudo apt-get install openoffice.org<br /> sudo apt-get install guake<br /> sudo apt-get install wicd<br /> sudo apt-get install psi<br /> sudo apt-get install qbittorent<br /> sudo apt-get install thunar<br /> sudo apt-get install xarchiver<br /> sudo apt-get install gedit<br /> sudo apt-get install iceweasel<br /> sudo apt-get install flashplugin-nonfree<br /> sudo apt-get install grandr<br /> sudo apt-get install tint2<br /> sudo apt-get install conky<br /> sudo apt-get install feh<br /> sudo apt-get install menu
  </p>
</div>

После установки всех пакетов уходим в ребут, логинимся, и видим серый экран и курсор мыши оО. Не удивляйтесь, так и должно быть) По нажатии правой кнопки мыши мы можем лицезреть меню openbox в котором уже должен быть пункт debian, где можно найти все установленные программы.  
Дальше все очень просто в каталоге /$HOME/.conig/ находим папки с конфигами openbox, tint2 и conky, редактируем конфигурационные файлы и наслаждаемся приятной работой отличной операционной системы ^^). Для примера ниже приведу свои конфиги, скажу только, что они не сильно изменены, ибо мне много не нужно =).  
***autostart.sh***

<a class='spoiler-tgl' href='https://doam.ru/retsept-prigotovleniya-debian-na-netbuke/#SID368_2_tgl' id='SID368_2_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID368_2' class='spoiler-body'>
  <p>
    feh &#8212;bg-scale ~/back1.jpg &<br /> conky -c ~/.config/conky/conkyrc -p 10 &<br /> tint2 &<br /> guake &<br /> wicd-gtk &<br /> psi &
  </p>
</div>

***rc.xml **(только мною добавленные секции, для регулировки звука и подсветки)*

<a class='spoiler-tgl' href='https://doam.ru/retsept-prigotovleniya-debian-na-netbuke/#SID368_3_tgl' id='SID368_3_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID368_3' class='spoiler-body'>
  <p>
    <!&#8212; zvuk + &#8212; &#8212;><br /> <keybind key=&#187;XF86AudioRaiseVolume&#187;><br /> <action name=&#187;Execute&#187;><br /> <command>amixer set Master 2+</command><br /> </action><br /> </keybind><br /> <keybind key=&#187;XF86AudioLowerVolume&#187;><br /> <action name=&#187;Execute&#187;><br /> <command>amixer set Master 2-</command><br /> </action><br /> </keybind><br /> <keybind key=&#187;XF86AudioMute&#187;><br /> <action name=&#187;Execute&#187;><br /> <command>amixer set Master toggle</command><br /> </action><br /> </keybind><br /> <!&#8212;PODSVETKA&#8212;><br /> <keybind key=&#187;XF86MonBrightnessUp&#187;><br /> <action name=&#187;Execute&#187;><br /> <command>sudo setpci -s 00:02.0 f4.b=99</command><br /> </action><br /> </keybind><br /> <keybind key=&#187;XF86MonBrightnessDown&#187;><br /> <action name=&#187;Execute&#187;><br /> <command>sudo setpci -s 00:02.0 f4.b=30</command><br /> </action><br /> </keybind><br /> <keybind key=&#187;XF86Launch1&#8243;><br /> <action name=&#187;Execute&#187;><br /> <command>sudo setpci -s 00:02.0 f4.b=00</command><br /> </action><br /> </keybind>
  </p>
</div>

***menu.xml***

<a class='spoiler-tgl' href='https://doam.ru/retsept-prigotovleniya-debian-na-netbuke/#SID368_4_tgl' id='SID368_4_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID368_4' class='spoiler-body'>
  <p>
    <?xml version=&#187;1.0&#8243; encoding=&#187;utf-8&#8243;?><br /> <openbox_menu xmlns=&#187;http://openbox.org/&#187; xmlns:xsi=&#187;http://www.w3.org/2001/XMLSchema-instance&#187; xsi:schemaLocation=&#187;http://openbox.org/ file:///usr/share/openbox/menu.xsd&#187;><br /> <menu id=&#187;root-menu&#187; label=&#187;Openbox 3&#8243;><br /> <item label=&#187;Терминал&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> guake<br /> </execute><br /> </action><br /> </item><br /> <item label=&#187;Браузер&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> google-chrome<br /> </execute><br /> </action><br /> </item><br /> <item label=&#187;Файлы&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> thunar<br /> </execute><br /> </action><br /> </item><br /> <!&#8212; This requires the presence of the &#8216;menu&#8217; package to work &#8212;><br /> <menu id=&#187;Debian&#187;/><br /> <separator/><br /> <menu id=&#187;client-list-menu&#187;/><br /> <separator/><br /> <item label=&#187;OpenboxConf&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> obconf<br /> </execute><br /> </action><br /> </item><br /> <item label=&#187;Reconfigure&#187;><br /> <action name=&#187;Reconfigure&#187;/><br /> </item><br /> <item label=&#187;Restart&#187;><br /> <action name=&#187;Restart&#187;/><br /> </item><br /> <separator/><br /> <menu id=&#187;root-menu-942538&#8243; label=&#187;Реальне?&#187;><br /> <item label=&#187;Гибернация&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> sudo pm-hibernate<br /> </execute><br /> </action><br /> </item><br /> <item label=&#187;Перезагрузка&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> sudo reboot<br /> </execute><br /> </action><br /> </item><br /> <item label=&#187;Выкл&#187;><br /> <action name=&#187;Execute&#187;><br /> <execute><br /> sudo halt<br /> </execute><br /> </action><br /> </item><br /> </menu><br /> <item label=&#187;Exit&#187;><br /> <action name=&#187;Exit&#187;/><br /> </item><br /> </menu><br /> </openbox_menu>
  </p>
</div>

***tint2rc***

<a class='spoiler-tgl' href='https://doam.ru/retsept-prigotovleniya-debian-na-netbuke/#SID368_5_tgl' id='SID368_5_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID368_5' class='spoiler-body'>
  <p>
    # Tint2 config file<br /> # Generated by tintwizard (http://code.google.com/p/tintwizard/)<br /> # For information on manually configuring tint2 see http://code.google.com/p/tint2/wiki/Configure
  </p>
  
  <p>
    # To use this as default tint2 config: save as $HOME/.config/tint2/tint2rc
  </p>
  
  <p>
    # Background definitions<br /> # ID 1<br /> rounded = 0<br /> border_width = 0<br /> background_color = #000000 40<br /> border_color = #000000 61
  </p>
  
  <p>
    # ID 2<br /> rounded = 3<br /> border_width = 1<br /> background_color = #000000 40<br /> border_color = #000000 61
  </p>
  
  <p>
    # Panel<br /> panel_monitor = all<br /> panel_position = bottom right horizontal<br /> panel_size = 100% 40<br /> panel_margin = 0 5<br /> panel_padding = 1 0 1<br /> panel_dock = 0<br /> wm_menu = 1<br /> panel_layer = top<br /> panel_background_id = 1<br /> font_shadow = 1
  </p>
  
  <p>
    # Panel Autohide<br /> autohide = 0<br /> autohide_show_timeout = 5<br /> autohide_hide_timeout = 5<br /> autohide_height = 0<br /> strut_policy = none
  </p>
  
  <p>
    # Taskbar<br /> taskbar_mode = single_desktop<br /> taskbar_padding = 2 3 2<br /> taskbar_background_id = 0<br /> #taskbar_active_background_id = 0
  </p>
  
  <p>
    # Tasks<br /> urgent_nb_of_blink = 8<br /> task_icon = 1<br /> task_text = 0<br /> task_centered = 1<br /> task_maximum_size = 80 28<br /> task_padding = 6 2<br /> task_background_id = 0<br /> task_active_background_id = 2<br /> task_urgent_background_id = 0<br /> task_iconified_background_id = 0
  </p>
  
  <p>
    # Task Icons<br /> task_icon_asb = 100 0 0<br /> task_active_icon_asb = 100 0 0<br /> task_urgent_icon_asb = 100 0 0<br /> task_iconified_icon_asb = 100 0 0
  </p>
  
  <p>
    # Fonts<br /> task_font = Sans 8<br /> task_font_color = #FFFFFF 100<br /> task_active_font_color = #FFFFFF 100<br /> task_urgent_font_color = #FFFFFF 100<br /> task_iconified_font_color = #FFFFFF 100<br /> font_shadow = 0
  </p>
  
  <p>
    # System Tray<br /> systray = 1<br /> systray_padding = 5 2 5<br /> systray_sort = ascending<br /> systray_background_id = 0<br /> systray_icon_size = 24<br /> systray_icon_asb = 100 0 0
  </p>
  
  <p>
    # Clock<br /> time1_format = %H:%M<br /> time1_font = FreeSans 10<br /> time2_format = %a %d %b<br /> time2_font = FreeSans 10<br /> clock_font_color = #12D0EB 100<br /> clock_tooltip =<br /> clock_padding = 5 2 5<br /> clock_background_id = 0
  </p>
  
  <p>
    # Tooltips<br /> tooltip = 0<br /> tooltip_padding = 0 0<br /> tooltip_show_timeout = 0<br /> tooltip_hide_timeout = 0<br /> tooltip_background_id = 0<br /> tooltip_font = Sans 12<br /> tooltip_font_color = #FFFFFF 100
  </p>
  
  <p>
    # Mouse<br /> mouse_middle = none<br /> mouse_right = none<br /> mouse_scroll_up = none<br /> mouse_scroll_down = none
  </p>
  
  <p>
    # Battery<br /> battery = 1<br /> battery_low_status = 20<br /> battery_low_cmd = notify-send &#171;battery low&#187;<br /> battery_hide = 0<br /> bat1_font = FreeSans 11<br /> bat2_font = FreeSans 11<br /> battery_font_color = #12D0EB 100<br /> battery_padding = 5 2 5<br /> battery_background_id = 0
  </p>
  
  <p>
    # End of config
  </p>
</div>

***Conky***

<a class='spoiler-tgl' href='https://doam.ru/retsept-prigotovleniya-debian-na-netbuke/#SID368_6_tgl' id='SID368_6_tgl' rev='blind||Показать »||Скрыть «||300'>Показать »</a>

<div id='SID368_6' class='spoiler-body'>
  <p>
    background no<br /> own_window yes<br /> own_window_colour brown<br /> own_window_transparent yes<br /> own_window_type override<br /> own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager<br /> double_buffer yes<br /> use_spacer left<br /> alignment top_right<br /> use_xft yes<br /> gap_x 10<br /> gap_y 15
  </p>
  
  <p>
    update_interval 1.0<br /> maximum_width 370<br /> stippled_borders 3<br /> border_width 10<br /> default_color black
  </p>
  
  <p>
    draw_outline no<br /> draw_borders no<br /> font Sans:size=10:weight=bold<br /> uppercase no<br /> draw_shades no<br /> override_utf8_locale yes<br /> format_human_readable yes
  </p>
  
  <p>
    TEXT
  </p>
  
  <p>
    ${color #12D0EB}${font Archangelsk:size=24} ${time %A}$font${color}
  </p>
  
  <p>
    ${color #12D0EB}${font Archangelsk:size=72} ${time %H:%M} $font ${color}
  </p>
  
  <p>
    ${color #12D0EB}${font Archangelsk:size=26} ${time %d} ${font Archangelsk:size=24} ${time %B} ${font Archangelsk:size=18} ${time %Y}${color}
  </p>
  
  <p>
    #${color #33ff00}${font Archangelsk:size=18}CPU:${color #ff0000} $cpu%<br /> #${color #33ff00}RAM:${color #ff0000} $memperc%<br /> #${color #711919}wlan0 up: ${upspeedf wlan0}k/s ${alignr}${totalup wlan0} total<br /> #${color #711919}eth0 up: ${upspeedf eth0}k/s ${alignr}${totalup eth0} total
  </p>
</div>

P.S. Конфиг conky принадлежит <a href="http://blog.elve.name/" target="_blank"> Ростиславу Беляеву</a>, спасибо ему за терпение и адекватные ответы на мои вопросы.
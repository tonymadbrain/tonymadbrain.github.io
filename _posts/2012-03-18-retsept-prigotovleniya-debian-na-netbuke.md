---
title: Рецепт приготовления debian на нетбуке
layout: post
permalink: /retsept-prigotovleniya-debian-na-netbuke/
tags:
  - Сonky
  - Debian
  - Linux
  - Openbox
  - Tint2
---

На новой работе, я понял, что операционная система windows абсолютно неудобная и не функциональная в контексте задач моего рабочего поста. И перешел к более полному познанию linux. Наиболее привлекательной для меня является ос debian, её и решено было использовать на моем нетбуке samsung n150. За пару месяцев затачивания ос "под себя", я умудрился несколько раз переустановить основную систему, зато это помогло довести процесс установки практически до автоматизма. Ниже будет представлен мой рецепт приготовлния debian, с индивидуальным набором приправ :)

<br>
<img  src="https://farm2.staticflickr.com/1643/24812267002_6b2148e948_o.jpg">
<br>
<br>

Итак, приступим. Debian полностью поддерживает все железо моего бука "из коробки", поэтому париться с драйверами особо не придется. Загрузочную флешку я всегда создаю с помощью ultraiso, google поможет в случае возникновения вопросов.
Установку основной системы я описывать не буду, скажу только, что лучше делать это с втыкнутым ethernet кабелем и сервером dhcp, так же советую использовать зеркало Яндекса. Так как windows мне все-таки нужен, для редких задач, под linux я выделил 120 гигабайт пространства на винчестере моего малыша samsung'a, 4 из них ушли под своп раздел (нет не много, я считаю, что swap раздел должен в два раза превышать объем оперативной памяти, и хоть пока в буке установлен 1 гигабайт, в дальнейшем я планирую заменить планку на 2 гиговую), 20 ушли под / - корень системы, а все оставшееся отдал на съедение разделу home.

Первым делом после запуска системы логинимся под рутом (надеюсь единственный раз) и редактируем файлик /etc/sudoers это можно сделать так же командой visudo. После строк

{% highlight bash %}
# User privilege specification
root ALL=(ALL) ALL
{% endhighlight %}

добавляем запись типа:
{% highlight bash %}
user ALL=(ALL) NOPASSWD:ALL
{% endhighlight %}

Где `user` ваше имя пользователя. После чего для получения прав суперпользователя нам не потребуется логиниться, а нужно будет всего лишь перед необходимой командой добавить - sudo, что означает выполнять от суперпользователя. Продолжаем, теперь отредактируем файл /etc/apt/sources.list в нем необходимо за комментировать строчку с cdrom (обычно первая), и добавить ftp репозиторий

{% highlight bash %}
deb http://ftp.debian.org/debian/ squeeze main non-free contrib
deb-src http://ftp.debian.org/debian/ squeeze main non-free contrib
{% endhighlight %}

После этого выполнить

{% highlight bash %}
sudo apt-get update
{% endhighlight %}

И можно приступать к забойной закачке пакетов (^^)

{% highlight bash %}
sudo apt-get install x-window-system openbox slim libreoffice guake wicd psi qbittorent thunar xarchiver gedit iceweasel flashplugin-nonfree grandr tint2 conky feh menu
{% endhighlight %}

После установки всех пакетов уходим в ребут, логинимся, и видим серый экран и курсор мыши оО. Не удивляйтесь, так и должно быть) По нажатии правой кнопки мыши мы можем лицезреть меню openbox в котором уже должен быть пункт debian, где можно найти все установленные программы.
Дальше все очень просто в каталоге /$HOME/.conig/ находим папки с конфигами openbox, tint2 и conky, редактируем конфигурационные файлы и наслаждаемся приятной работой отличной операционной системы ^^). Для примера ниже приведу свои конфиги, скажу только, что они не сильно изменены, ибо мне много не нужно =).

*autostart.sh*

{% highlight bash %}
feh -bg-scale ~/back1.jpg &
conky -c ~/.config/conky/conkyrc -p 10 &
tint2 &
guake &
wicd-gtk &
psi &
{% endhighlight %}

*rc.xml*(только мною добавленные секции, для регулировки звука и подсветки)

{% highlight bash %}
<!-- zvuk + -->
  <keybind key="XF86AudioRaiseVolume">
    <action name="Execute">
      <command>amixer set Master 2+</command>
    </action>
  </keybind>
  <keybind key="XF86AudioLowerVolume">
    <action name="Execute">
      <command>amixer set Master 2-</command>
    </action>
  </keybind>
  <keybind key="XF86AudioMute">
    <action name="Execute">
      <command>amixer set Master toggle</command>
    </action>
  </keybind>
<!--PODSVETKA-->
  <keybind key="XF86MonBrightnessUp">
    <action name="Execute">
      <command>sudo setpci -s 00:02.0 f4.b=99</command>
    </action>
  </keybind>
  <keybind key="XF86MonBrightnessDown">
    <action name="Execute">
      <command>sudo setpci -s 00:02.0 f4.b=30</command>
    </action>
  </keybind>
  <keybind key="XF86Launch1">
    <action name="Execute">
      <command>sudo setpci -s 00:02.0 f4.b=00</command>
    </action>
  </keybind>
{% endhighlight %}

*menu.xml*

{% highlight bash %}
<?xml version="1.0" encoding="utf-8"><openbox_menu xmlns="http://openbox.org/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://openbox.org/ file:///usr/share/openbox/menu.xsd">
<menu id="root-menu" label="Openbox 3">
  <item label="Терминал">
    <action name="Execute">
      <execute>
        guake
      </execute>
    </action>
  </item>
  <item label="Браузер">
    <action name="Execute">
      <execute>
        google-chrome
      </execute>
    </action>
  </item>
  <item label="Файлы">
    <action name="Execute">
      <execute>
        thunar
      </execute>
    </action>
  </item>
<!-- This requires the presence of the "menu" package to work -->
  <menu id="Debian"/>
    <separator/>
      <menu id="client-list-menu"/>
        <separator/>
          <item label="OpenboxConf">
            <action name="Execute">
              <execute>
                obconf
              </execute>
            </action>
          </item>
          <item label="Reconfigure">
            <action name="Reconfigure"/>
          </item>
          <item label="Restart">
            <action name="Restart"/>
          </item>
        <separator/>
      <menu id="root-menu-942538" label="Реальне?">
        <item label="Гибернация">
          <action name="Execute">
            <execute>
              sudo pm-hibernate
            </execute>
          </action>
        </item>
        <item label="Перезагрузка">
          <action name="Execute">
            <execute>
              sudo reboot
            </execute>
          </action>
        </item>
        <item label="Выкл">
          <action name="Execute">
            <execute>
              sudo halt
            </execute>
          </action>
        </item>
      </menu>
    <item label="Exit">
      <action name="Exit"/>
    </item>
  </menu>
</openbox_menu>
{% endhighlight %}

*tint2rc*

{% highlight bash %}
# Tint2 config file
# Generated by tintwizard (http://code.google.com/p/tintwizard/)
# For information on manually configuring tint2 see http://code.google.com/p/tint2/wiki/Configure
# To use this as default tint2 config: save as $HOME/.config/tint2/tint2rc
# Background definitions

# ID 1
rounded = 0
border_width = 0
background_color = #000000 40
border_color = #000000 61

# ID 2
rounded = 3
border_width = 1
background_color = #000000 40
border_color = #000000 61

# Panel
panel_monitor = all
panel_position = bottom right horizontal
panel_size = 100% 40
panel_margin = 0 5
panel_padding = 1 0 1
panel_dock = 0
wm_menu = 1
panel_layer = top
panel_background_id = 1
font_shadow = 1

# Panel Autohide
autohide = 0
autohide_show_timeout = 5
autohide_hide_timeout = 5
autohide_height = 0
strut_policy = none

# Taskbar
taskbar_mode = single_desktop
taskbar_padding = 2 3 2
taskbar_background_id = 0
#taskbar_active_background_id = 0

# Tasks
urgent_nb_of_blink = 8
task_icon = 1
task_text = 0
task_centered = 1
task_maximum_size = 80 28
task_padding = 6 2
task_background_id = 0
task_active_background_id = 2
task_urgent_background_id = 0
task_iconified_background_id = 0

# Task Icons
task_icon_asb = 100 0 0
task_active_icon_asb = 100 0 0
task_urgent_icon_asb = 100 0 0
task_iconified_icon_asb = 100 0 0

# Fonts
task_font = Sans 8
task_font_color = #FFFFFF 100
task_active_font_color = #FFFFFF 100
task_urgent_font_color = #FFFFFF 100
task_iconified_font_color = #FFFFFF 100
font_shadow = 0

# System Tray
systray = 1
systray_padding = 5 2 5
systray_sort = ascending
systray_background_id = 0
systray_icon_size = 24
systray_icon_asb = 100 0 0

# Clock
time1_format = %H:%M
time1_font = FreeSans 10
time2_format = %a %d %b
time2_font = FreeSans 10
clock_font_color = #12D0EB 100
clock_tooltip =
clock_padding = 5 2 5
clock_background_id = 0

# Tooltips
tooltip = 0
tooltip_padding = 0 0
tooltip_show_timeout = 0
tooltip_hide_timeout = 0
tooltip_background_id = 0
tooltip_font = Sans 12
tooltip_font_color = #FFFFFF 100

# Mouse
mouse_middle = none
mouse_right = none
mouse_scroll_up = none
mouse_scroll_down = none

# Battery
battery = 1
battery_low_status = 20
battery_low_cmd = notify-send "battery low"
battery_hide = 0
bat1_font = FreeSans 11
bat2_font = FreeSans 11
battery_font_color = #12D0EB 100
battery_padding = 5 2 5
battery_background_id = 0

# End of config
{% endhighlight %}

*Conky*

{% highlight bash %}
background no
own_window yes
own_window_colour brown
own_window_transparent yes
own_window_type override
own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
double_buffer yes
use_spacer left
alignment top_right
use_xft yes
gap_x 10
gap_y 15

update_interval 1.0
maximum_width 370
stippled_borders 3
border_width 10
default_color black

draw_outline no
draw_borders no
font Sans:size=10:weight=bold
uppercase no
draw_shades no
override_utf8_locale yes
format_human_readable yes

TEXT
${color #12D0EB}${font Archangelsk:size=24} ${time %A}$font${color}
${color #12D0EB}${font Archangelsk:size=72} ${time %H:%M} $font ${color}
${color #12D0EB}${font Archangelsk:size=26} ${time %d} ${font Archangelsk:size=24} ${time %B} ${font Archangelsk:size=18} ${time %Y}${color}
#${color #33ff00}${font Archangelsk:size=18}CPU:${color #ff0000} $cpu%
#${color #33ff00}RAM:${color #ff0000} $memperc%
#${color #711919}wlan0 up: ${upspeedf wlan0}k/s ${alignr}${totalup wlan0} total
#${color #711919}eth0 up: ${upspeedf eth0}k/s ${alignr}${totalup eth0} total
{% endhighlight %}

P.S. Конфиг conky принадлежит <a href="http://blog.elve.name/" target="_blank"> Ростиславу Беляеву</a>, спасибо ему за терпение и адекватные ответы на мои вопросы.

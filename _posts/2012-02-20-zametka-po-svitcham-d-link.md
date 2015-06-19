---
title: Заметка по свитчам D-link
layout: post
permalink: /zametka-po-svitcham-d-link/
redirect_from: "/?p=354"
categories:
  - root
tags:
  - D-link
  - Заметка
  - Команды
  - Свитчи
---
Команды для свитчей д-линк:

{% highlight bash %}
show ports
{% endhighlight %}
Показать инфо о портах  
{% highlight bash %}  
config ports x state enable  
{% endhighlight %}
Включить порт
{% highlight bash %}
config ports x state disable  
{% endhighlight %}
Выключить порт
{% highlight bash %}
config bandwidth_control <portlist>  
{% endhighlight %}
Изменение скорости
{% highlight bash %}
config vlan default(имя влана) delete xx  
config vlan v996 (имя влана) add untagged xx  
{% endhighlight %}
Изменение влана
{% highlight bash %}
show switch  
{% endhighlight %}
Отображение информации о коммутаторе. Важно: не путать версию прошивки и версию конфига
{% highlight bash %}
show log  
{% endhighlight %}
Просмотр логов коммутатора

Варианты записей присутствующих в логах коммутатора:
{% highlight bash %}
7028 2008/10/23 18:51:57 Port 19 link down &#8212; упал линк на 19-м порту  
7029 2008/10/23 18:52:01 Port 19 link up, 100Mbps FULL duplex &#8212; линк поднялся на 19-м порту установлена скорость передачи 100Mb установлен режим полного дуплекса  
7045 2008/10/23 19:28:19 Multicast storm is occurring (port: 18) &#8212; зафиксирован мультикаст шторм на 18 порту.  
7035 2008/10/23 19:06:19 Multicast storm has cleared (port: 8) &#8212; мультикаст шторм был очищен  
7313 2008/10/24 21:59:16 Broadcast storm is occurring (port: 15) &#8212; зафиксирован броадкаст шторм на 18 порту.  
7429 2008/10/25 14:11:12 Broadcast storm has cleared (port: 18) &#8212; броадкаст шторм был очищен
{% endhighlight %}
Если в логах коммутатора вы видите записи о том что на всех активных портах одновременно были зафиксированы броадкаст и мультикаст шторм, коммутатор перезагружался.
{% highlight bash %}
show ports description  
{% endhighlight %}
Просмотр описания порта
{% highlight bash %}
config ports X description  
{% endhighlight %}
Добавить описание порта
{% highlight bash %}
show arpentry  
{% endhighlight %}
Отображает ARP-кэш. В D-Link нет функции поиска IP по заданному MAC&#8217;y, поэтому при необходимости такого поиска приходится выводить весь кэш на экран и искать вручную.
{% highlight bash %}
show utilization cpu  
{% endhighlight %}
Отображение загрузки центрального процессора, за последние 5 секунд, минуту и 5 минут.
{% highlight bash %}
show utilization ports  
{% endhighlight %}
Отображение загрузки портов в PPS (пакеты в секунду)
{% highlight bash %}
show ipif  
{% endhighlight %}
Отображение информации по всем сконфигурированным интерфейсам на данном свитче.
{% highlight bash %}
show iproute  
{% endhighlight %}
Отображение таблицы маршрутизации свитча  
{% highlight bash %}
sh fdb  
{% endhighlight %}
Отображение всех сконфигурированных интерфейсов свитча и MAC-адреса подключенных к ним устройств.
{% highlight bash %}
show error ports <№ порта>  
{% endhighlight %}
Отображение ошибок передачи пакетов на заданном порту  

#### Типы ошибок:  

* CRC Error &#8212; ошибки проверки контрольной суммы  

* Undersize &#8212; возникают при получение фрейма размером 61-64 байта. Фрейм передается дальше, на работу не влияет  

* Oversize &#8212; возникают при получении пакета размером более 1518 байт и правильной контрольной суммой  

* Jabber &#8212; возникает при получении пакета размером более 1518 байт и имеющего ошибки в контрольной сумме  

* Drop Pkts &#8212; пакеты отброшенные в одном из трех случаев:  
  * Переполнение входного буфера на порту  
  * Пакеты, отброшенные ACL  
  * Проверка по VLAN на входе  

* Fragment &#8212; количество принятых кадров длиной менее 64 байт (без преамбулы и начального ограничителя кадра, но включая байты FCS &#8212; контрольной суммы) и содержащих ошибки FCS или ошибки выравнивания.  

* Excessive Deferral &#8212; количество пакетов, первая попытка отправки которых была отложена по причине занятости среды передачи.  

* Collision &#8212; возникают, когда две станции одновременно пытаются передать кадр данных по общей сред  

* Late Collision &#8212; возникают, если коллизия была обнаружена после передачи первых 64 байт пакета  

* Excessive Collision &#8212; возникают, если после возникновения коллизии последующие 16 попыток передачи пакета окончались неудачей. данный пакет больше не передается  

* Single Collision &#8212; единичная коллизия

{% highlight bash %}
show fdb port <№ порта>  
{% endhighlight %}
Отображение MAC-адресов на заданном порту
{% highlight bash %}
show fdb mac_address <MAC-адрес>  
{% endhighlight %}
Отображает принадлежность MAC-адреса порту коммутатора
{% highlight bash %}
show packet ports <№ порта>  
{% endhighlight %}
Отображение статистики трафика на порту в реальном времени.

* RX &#8212; пакеты приходящие от клиента  
* TX &#8212; пакеты приходящие к клиенту

{% highlight bash %}
show traffic control  
{% endhighlight %}
Отображение настроек storm control на коммутаторе. Должно быть отключено для аплинков, каскадных портов и всех портов узловых коммутаторов.

Параметры настроек имеют вид Enabled(Disabled)/10/S(D)  

* Enabled(Disabled) &#8212; показывает включен ли шторм контроль для данного порта  

* Числовое значение &#8212; кол-во пакетов при превышение, которого срабатывает шторм контроль  

* S(D) &#8212; действие выполняемое с пакетами. S &#8212; блокируется весь трафик на порту. D &#8212; пакеты отбрасываются  

* В колонке Time Interval указывается продолжительность дествия над трафиком.

{% highlight bash %}
show mac_notification  
{% endhighlight %}
Отображение настроек уведомления о появлении новых MAC-адресов на порту коммутатора. Должно быть отключено для аплинков, каскадных портов и всех портов узловых коммутаторов.

{% highlight bash %}
show port_security  
{% endhighlight %}
Отображение настроек контроля MAC-адресов. Должно быть отключено для аплинков, каскадных портов и всех портов узловых коммутаторов.

{% highlight bash %}
show stp  
{% endhighlight %}
Отображение настроек протокола STP на коммутаторе

{% highlight bash %}
show arpentry ipaddress <IP-адрес>  
{% endhighlight %}
Поиск записи с данным IP-адресом в arp-таблице.

{% highlight bash %}
show dhcp_relay  
{% endhighlight %}
Отображение настроек dhcp_relay на коммутаторе. Обязательно должно быть включено в сегментированном районе, выключено в несегментированном.

Пример вывода:  
{% highlight bash %}
Command: show dhcp_relay  
DHCP/BOOTP Relay Status : Enabled &#8212; включена или выключена функция  
DHCP/BOOTP Hops Count Limit : 16  
DHCP/BOOTP Relay Time Threshold : 0  
DHCP Relay Agent Information Option 82 State : Enabled  
DHCP Relay Agent Information Option 82 Check : Disabled  
DHCP Relay Agent Information Option 82 Policy : Keep  
Interface Server 1 Server 2 Server 3 Server 4  
&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;  
System 83.102.233.203 &#8212; адрес централизованного DHCP-сервера
{% endhighlight %}

{% highlight bash %}
show bandwidth_control <№ порта>  
{% endhighlight %}
Отображение настроек полосы пропускание для заданного порта.

{% highlight bash %}
show traffic_segmentation <№ порта>  
{% endhighlight %}
Отображение настроек сегментации трафика для заданного порта

{% highlight bash %}
show current\_config access\_profile  
{% endhighlight %}
Отображение настроек ACL по всем портам (На свичах DES-3028 команда show access_profile) .

Пример вывода:  
{% highlight bash %}
config access\_profile profile\_id 150 add access\_id 24 ip destination\_ip 0.0.0.0 port 24 deny (150 &#8212; номер правила, далее указывается, что блокируется этим правилом, порт на который действует данное правило, состояние правила deny &#8212; запрещено, permit &#8212; разрешено)
{% endhighlight %}

{% highlight bash %}
show vlan  
{% endhighlight %}
Отображение настроек Vlan на коммутаторе.

{% highlight bash %}
cable_diag ports  
{% endhighlight %}
Диагностическая утилита для проверки длины кабеля (показывает результат только на юзерских портах (1-24)) Доступна без enable на DES-3526 с прошивкой 6.00.B25, а также на DES-3028. Примеры вывода ниже.

Линк на порту есть, все работает нормально:  
{% highlight bash %}
Command: cable_diag ports 1  
Perform Cable Diagnostics &#8230;  
Port Type Link Status Test Result Cable Length (M)  
&#8212;- &#8212;&#8212; &#8212;&#8212;&#8212;&#8212;- &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;-  
1 FE Link Up OK 88
{% endhighlight %}

В следующем случае вариантов может быть несколько:

* Кабель целый, все работает отлично;  
* Кабель целый, просто вытащен из компа;  
* Кабель целый, в сетевую воткнут, но сам ПК выключен;  
* Кабель аккуратно срезан. При диагностике стоит учитывать, что разница в один метр &#8212; совершенно нормальная ситуация &#8212; в UTP отдельные пары идут с различным шагом скрутки (одна пара более &#171;витая&#187;, чем другая).

{% highlight bash %}  
Command: cable_diag ports 1  
Perform Cable Diagnostics &#8230;  
Port Type Link Status Test Result Cable Length (M)  
&#8212;- &#8212;&#8212; &#8212;&#8212;&#8212;&#8212;- &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;-  
1 FE Link Down Pair1 Open at 83 M &#8212;  
Pair2 Open at 84 M  
{% endhighlight %}

Видимо проблема с кабелем, а именно повреждены жилы:  
{% highlight bash %}
Command: cable_diag ports 1  
Perform Cable Diagnostics &#8230;  
Port Type Link Status Test Result Cable Length (M)  
&#8212;- &#8212;&#8212; &#8212;&#8212;&#8212;&#8212;- &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;-  
1 FE Link Down Pair2 Open at 57 M &#8212;  
{% endhighlight %}

Кабель не подключен к свитчу:  
{% highlight bash %}
Command: cable_diag ports 1  
Perform Cable Diagnostics &#8230;  
Port Type Link Status Test Result Cable Length (M)  
&#8212; &#8212;&#8212; &#8212;&#8212;&#8212;&#8212;- &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;-  
1 FE Link Down No Cable &#8212;
{% endhighlight %}

Кабель обрезан на 48 метре:  
{% highlight bash %}
Command: cable_diag ports 1  
Perform Cable Diagnostics &#8230;  
Port Type Link Status Test Result Cable Length (M)  
&#8212;- &#8212;&#8212; &#8212;&#8212;&#8212;&#8212;- &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;-  
1 FE Link Down Pair1 Short at 48 M &#8212;  
Pair2 Short at 48 M  
{% endhighlight %}

Питание по кабелю есть, но измерить длину невозможно:  
{% highlight bash %}
Command: cable_diag ports 1  
Perform Cable Diagnostics &#8230;  
Port Type Link Status Test Result Cable Length (M)  
&#8212;- &#8212;&#8212; &#8212;&#8212;&#8212;&#8212;- &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212; &#8212;&#8212;&#8212;&#8212;&#8212;-  
1 FE Link Down ОК &#8212;
{% endhighlight %}

{% highlight bash %}
show lldp remote_ports  
{% endhighlight %}
Отображение следующего оборудования на порту (отображает мак адрес во 2й строчке).

Пример вывода: Command: show lldp remote_ports 26

{% highlight bash %}
Port ID : 26  
Remote Entities count : 1 Entity 1  
Chassis Id Subtype : MACADDRESS  
Chassis Id : 00-1E-58-AE-DC-14  
Port Id Subtype : LOCAL  
Port ID : 1/25  
Port Description : D-Link DES-3028 R2.50 Port 25  
System Name : P1CV186021772-1#B340237#B340238  
System Description : Fast Ethernet Switch  
System Capabilities : Repeater, Bridge,  
Management Address count : 1  
Port PVID : 0  
PPVID Entries count : 0  
VLAN Name Entries count : 0  
Protocol ID Entries count : 0  
MAC/PHY Configuration/Status : (None)  
Power Via MDI : (None)  
Link Aggregation : (None)  
Maximum Frame Size : 0  
Unknown TLVs count : 0
{% endhighlight %}

{% highlight bash %}
show address_binding dhcp_snoop binding_entry  
{% endhighlight %}

Просмотр таблицы dhcp snooping binding
<div></div>
Функция IP-MAC-Port Binding в коммутаторах D-Link позволяет контролировать доступ компьютеров в сеть на основе их IP и MAC-адресов, а также порта подключения. Если какая-нибудь составляющая в этой записи меняется, то коммутатор отбрасывает фреймы от этого мака (аналог фунции IP Source Address Guard на Alcatel&#8217;ях). Соответствие мака, порта и ip коммутатор проверяет по таблице dhcp snooping binding. Посмотреть эту таблицу можно командой show address\_binding dhcp\_snoop binding_entry. Соответственно, если с кокого-либо порта уходят ip-пакеты, в которых ip-адрес отправителя отличен от указанного в этой таблице (скажем 169.254.255.5 или 0.0.0.0, или некорректная статика), то свич такие пакеты отбрасывает, при этом занося в лог следующую запись:

{% highlight bash %}
Unauthenticated IP-MAC address and discardet by ip mac port binding (IP 169.254.255.5, MAC 00-24-26-35-56-08, port: 19)
{% endhighlight %}
---
title: Смена логотипа в Redmine
author: madman
layout: post
permalink: /smena-logotipa-v-redmine/
categories:
  - CentOS
tags:
  - apache
  - changelogo
  - logo
  - nginx
  - redmine
  - tips
---
Решил для себя перевести статью по <a href="http://www.redmine.org/projects/redmine/wiki/Howto_add_a_logo_to_your_Redmine_banner" target="_blank">добавлению логотипа в заголовок Redmine</a>. В моем случае проверялось на теме Alternate.  
Редактируем файлик base.html.erb  
Например

<pre># vim /opt/redmine/app/views/layouts/base.html.erb</pre>

Находим строку

<pre>&lt;h1&gt;&lt;%= page_header_title %&gt;&lt;/h1&gt;</pre>

<!--more-->И комментируем

<pre>&lt;!--&lt;h1&gt;&lt;%= page_header_title %&gt;&lt;/h1&gt;--&gt;
</pre>

В следующую строчку вставляем

<pre>&lt;img src="&lt;%= Redmine::Utils.relative_url_root %&gt;/images/logo.png" style="top-margin: 15px; left-margin: 15px;"/&gt;</pre>

<%= Redmine::Utils.relative\_url\_root %> &#8212; переменная, которая указывает на каталог установки redmine.  
В итоге, правки должны выглядеть вот так

<pre>&lt;/div&gt;
&lt;!--&lt;h1&gt;&lt;%= page_header_title %&gt;&lt;/h1&gt;--&gt;
&lt;img src="&lt;%= Redmine::Utils.relative_url_root %&gt;/images/logo.png" style="top-margin: 15px; left-margin: 15px;"/&gt;

&lt;% if display_main_menu?(@project) %&gt;</pre>

Теперь нужно загрузить изображение

<pre>scp logo.png root@example.com:/opt/redmine/public/images</pre>

Не забываем выставить права на файл

<pre>chown redmine:redmine /opt/redmine/public/images/logo.png</pre>

Ну и теперь осталось перезагрузить redmine, для этого перезагружаем веб-сервер:

<pre># service apache2 restart
# service httpd restart
# service nginx restart
</pre>

Только в статье не указано, что изображение ни как не будет деформировано, т.е. если загрузить 100х100 будет отображаться 100х100, если 1024х1024 будет такое и сдвинет все остальные элементы. Еще, при редактировании фирменного логотипа, я сделал прозрачный фон, чтобы не пытаться попасть в цвет шапки redmine.
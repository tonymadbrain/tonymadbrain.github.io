---
title: Смена логотипа в Redmine
layout: post
permalink: /how_to_change_logo_in_redmine/
redirect_from: /smena-logotipa-v-redmine/
excerpt: ""
tags:
  - Apache
  - Changelogo
  - Logo
  - Nginx
  - Redmine
  - Tips
---

Решил для себя перевести статью по <a href="http://www.redmine.org/projects/redmine/wiki/Howto_add_a_logo_to_your_Redmine_banner" target="_blank">добавлению логотипа в заголовок Redmine</a>. В моем случае проверялось на теме Alternate.
<br>
<br>
Редактируем файлик base.html.erb

{% highlight bash %}
$ vim /opt/redmine/app/views/layouts/base.html.erb
{% endhighlight %}

Находим строку:

{% highlight erb %}
<h1><%= page_header_title %></h1>
{% endhighlight %}

И комментируем

{% highlight html %}
<!--<h1><%= page_header_title %></h1>-->
{% endhighlight %}

В следующую строчку вставляем

{% highlight erb %}
<img src="<%= Redmine::Utils.relative_url_root %>/images/logo.png" style="top-margin: 15px; left-margin: 15px;"/>
{% endhighlight %}

`Redmine::Utils.relative_url_root` - переменная, которая указывает на каталог установки redmine.
<br>
<br>
В итоге, правки должны выглядеть вот так:

{% highlight erb %}
</div>
<!--<h1><%= page_header_title %></h1>-->
<img src="<%= Redmine::Utils.relative_url_root %>/images/logo.png" style="top-margin: 15px; left-margin: 15px;"/>

<% if display_main_menu?(@project) %>
{% endhighlight %}

Теперь нужно загрузить изображение

{% highlight bash %}
$ scp logo.png root@example.com:/opt/redmine/public/images
{% endhighlight %}

Не забываем выставить права на файл

{% highlight bash %}
$ chown redmine:redmine /opt/redmine/public/images/logo.png
{% endhighlight %}

Ну и теперь осталось перезагрузить redmine, для этого перезагружаем веб-сервер:

{% highlight bash %}
$ service apache2 restart
$ service httpd restart
$ service nginx restart
{% endhighlight %}

Только в статье не указано, что изображение ни как не будет деформировано, т.е. если загрузить 100х100 будет отображаться 100х100, если 1024х1024 будет такое и сдвинет все остальные элементы. Еще, при редактировании фирменного логотипа, я сделал прозрачный фон, чтобы не пытаться попасть в цвет шапки redmine.

---
layout: post
title: React.js - tutorial для Rails разработчиков (часть 2)
permalink: /react-js-for-rails-developers-part-2/
excerpt: Учимся работать с React в Rails
tags:
  - Ruby
  - RubyOnRails
  - React
  - Tutorial
date: 2016-02-12T08:19:48+03:00
---

##Вместо вступления

Так как материал получается довольно объемным, я решил разделить его на две части и это вторая:

1. <a href="http://doam.ru/react-js-for-rails-developers-part-1/" target="_blank">React.js - tutorial для Rails разработчиков (часть 1)</a>
2. <a href="http://doam.ru/react-js-for-rails-developers-part-2/" target="_blank">React.js - tutorial для Rails разработчиков (часть 2)</a>

В первой части мы создаем приложение, ресурс в Rails и компонент в React, разбираемся с Parent-child взаимодействием и компонентами, которые можно использовать несколько раз (реюзабельные).

{% include _toc.html %}

<br>
<img src="https://farm2.staticflickr.com/1480/23858108174_a563951ceb_o.jpg">
<br>

> От переводчика: <a href="https://www.airpair.com/reactjs/posts/reactjs-a-guide-for-rails-developers" target="_blank">Оригинал статьи</a>

##setState/replaceState: Удаляем записи

Следующая функция в нашем списке это возможность удалять записи, нам нужна новая колонка `Actions` в таблице с записями. В этой колонке будет находиться кнопка `Delete` для каждой записи. Как и в предыдущем примере, нам нужно создать метод `destroy` в контроллере Rails:

{% highlight ruby %}
# app/controllers/records_controller.rb

class RecordsController < ApplicationController
  ...

  def destroy
    @record = Record.find(params[:id])
    @record.destroy
    head :no_content
  end

  ...
end
{% endhighlight %}

That is all the server-side code we will need for this feature. Now, open your Records React component and add the Actions column at the rightmost position of the table header:







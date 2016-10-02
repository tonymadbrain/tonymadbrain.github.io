---
layout: post
title: Добавление статических страниц в Rails приложение
excerpt: "С использованием high_voltage"
permalink: /adding_static_pages_to_your_rails_app/
tags:
  - Rails
  - Ruby
  - Tutorial
date: 2016-10-02T22:23:54+03:00
---

Рано или поздно вы захотите добавить в ваше Rails приложение страницы которые не создаются динамически, но содержат какую-нибудь маркетинговую или юридическую информацию или даже лендинги которые ведут, например, на вашу главную страницу.

> От переводчика: <a href="https://christoph.luppri.ch/articles/2016/09/25/adding-static-pages-to-your-rails-app/" target="_blank">Оригинал статьи</a>

Конечно же вы можете накидать для этого собственные контроллер, маршруты и вьюхи (views). Но есть более простое решение: <a href="https://github.com/thoughtbot/high_voltage" target="_blank">high_voltage</a>. Этот гем, созданный ребятами из <a href="https://thoughtbot.com/" target="_blank">thoughbot</a>, позволяет создавать статические страницы на одном дыхании. Давайте начнем.
<br>
<br>
Добавим его в `Gemfile` и создадим новую директорию `pages` в нашем каталоге с вьюхами (app/views). Затем, создадим новую вьюху внутри каталога `pages`. Допустим нам нужна страница `imprint`, так что мы назавем наш файл `imprint.html.erb`. Если вы используете какой-либо другой язык шаблонизации как `slim` или `haml`, просто адаптируйте расширение файла. Осталось только открыть страницу `http://localhost:3000/pages/imprin` в браузере и *вуаля* - статическая страница imprint будет показана.

###Бонус

Одна вещь, которую вы, скорее всего, захотите изменить это структуруа URL. Таким образом, чтобы ваши статические страницы были доступны по адресу от корня сайта а не через `pages`. Например в нашем случае чтобы вместо `example.com/pages/imprint` использовать `example.com/imprint`. Для этого создайте новый файл в каталоге `initializers` в корне Rails приложения с именем `high_voltage.rb` и следующим содержимым:

{% highlight ruby %}
HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
end
{% endhighlight %}

После перезапуска `rails server` страница будет доступна по адресу `http://localhost:3000/imprint`.


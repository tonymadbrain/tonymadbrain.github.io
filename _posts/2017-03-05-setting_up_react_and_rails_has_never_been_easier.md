---
layout: post
title: Настройка React + Rails никогда не была проще
excerpt: "Релиз Rails 5.1 beta 1 принес много frontend изменений"
permalink: /setting_up_react_and_rails_has_never_been_easier/
tags:
  - Rails
  - React
  - Tutorial
image:
  graph: https://farm1.staticflickr.com/590/32445618893_0efe70151b_o.jpg
date: 2017-03-05T12:34:17+03:00
---

<figure>
  <img src="https://farm1.staticflickr.com/590/32445618893_0efe70151b_o.jpg"></a>
</figure>

> От переводчика: <a href="https://blog.kodius.io/2017/02/28/rails-react-boilerplate-example/" target="_blank">Оригинал статьи</a>

> От переводчика: Я всегда стараюсь как можно точнее переводить статьи для своего блога, но в данном случае чтобы предоставить наиболее свежую и точную инструкцию мне пришлось поправить некоторые моменты. Я уже писал о технологиях применяемых в данном туториале, прежде чем начать вы можете ознакомиться с этими запиясми: <a href="http://doam.ru/rails-webpack-heroku/">Деплоим Rails + Webpack приложение на Heroku</a>, <a href="http://doam.ru/react_js_for_rails_developers_part_1/">React.js - tutorial для Rails разработчиков (часть 1)</a>, <a href="http://doam.ru/react_js_for_rails_developers_part_2/">React.js - tutorial для Rails разработчиков (часть 2)</a>

Буквально несколько дней назад была выпущена Бета 1 Rails 5.1, которая принесла кучу новых функций. Наиболее заметной из них является добавление <a href="https://github.com/webpack/webpack" target="_blank">Webpack</a>. Для тех кто не в курсе, Webpack это инструмент для сборки вашего JavaScript. Вместе с ним также был добавлен Yarn - менеджер зависимостей для Node пакетов. Эти два инструмента решительно упрощают настройку Rails приложений совместно с React (ныне главная головная боль), Angular, Vue или другими JavaScript фреймворками. В релизе также присутствует такое заметное изменение как удаление jQuery, больше он не является частью Rails по умолчанию.
<br>
<br>
Я продемонстрирую очень простую установку Rails + React.
<br>
<br>
Код приложения шаблона React+Rails доступен на <a href="https://github.com/kodius/boilerplate-react-rails" target="_blank">Github</a>.
<br>
<br>
Чтобы начать, нам нужно получить самую последнюю версию Rails. К счастью, есть очень простой способ для этого. Вместо того чтобы вручную выбирать версию и возиться с Gemfile, мы просто выполним команду

{% highlight bash %}
$ gem install rails --pre
{% endhighlight %}

> От переводчика: Для управления разными версиями Ruby и наборами гемов я использую RVM, например <a href="http://doam.ru/creating_new_app_in_rails/">вот в этой статье</a> я описал как создать отдельный gemset (набор гемов) и закрепить его за проектом.

После того как с этим покончено, мы можем создать Rails проект используя инструкцию ниже. В данном конкретном случае мы не будем устанавливать CoffeeScript и Turbolinks, так как приложение их не использует.

{% highlight bash %}
$ rails new test_app - dev - force --webpack --skip-coffee --skip-turbolinks
{% endhighlight %}

Обратите внимание, что <a href="https://github.com/yarnpkg/yarn" target="_blank">Yarn</a> должен быть установлен в системе до запуска данной команды, чтобы Rails мог сконфигурировать все правильно, однако если вы запустили команду выше в тот момент когда Yarn не был установлен, вы можете доустановить все требуемые пакеты позже.
<br>
<br>
Установить Yarn на macOS можно с помощью `Homebrew` командой `brew install yarn`. А доустановить все требуемые пакеты вот так

{% highlight bash %}
$ yarn add --dev babel-core babel-loader babel-preset-latest babel-preset-react babel-preset-env coffee-loader coffee-script glob path-complete-extname rails-erb-loader webpack webpack-dev-server webpack-merge
{% endhighlight %}

Yarn скачает все необходимые зависимости и сохранит статус в lock файл.
<br>
<br>
Затем мы установим React используя наш локальный бинарный файл Rails и новую утилиту командной строки `webpacker`.

{% highlight bash %}
$ bin/rails webpacker:install:react
{% endhighlight %}

Эта команда автоматически подтянет всё что нужно чтобы использовать React. Вы заметите новые каталоги/файлы, в том числе `webpack`, `webpack-dev-server` и `yarn` внутри `bin`, а также множество других конфигурационных файлов, с которыми вам стоит разобраться в будущем, если планируете использовать данную связку.
<br>
<br>
Согласно новой структуре внутри папки `app` появится каталог `javascript`, внутри которого, в свою очередь, появится папка `packs`. Это будет место где нужно складывать наши *пакеты* (packs) чтобы Webpack узнал о их существовании.
<br>
<br>
Теперь сделаем необходимые *вещи* на стороне Rails. Чтобы объединить Rails и React в одно целое, мы будем использовать новые webpack теги внутри наших шаблонов. Для начала создадим минимальый контроллер, конечно же

{% highlight bash %}
$ rails g controller Main index
{% endhighlight %}

Теперь, внутри нашего шаблона `app/views/main/index.html.erb` заменим содержимое на

{% highlight javascript %}
<%= javascript_pack_tag 'hello_react' %>
{% endhighlight %}

hello_react - это пакет (pack) который уже существует по пути `app/javascript/packs/hello_react.jsx` благодаря Webpack React генератору встроенному в Rails.
<br>
<br>
Однако, этого недостаточно чтобы наша связка React+Rails заработала. Что же нам делать? Открыть файл `config/environments/development.rb` и раскомментировать 3 строку содержащую следующий параметр

{% highlight ruby %}
...
config.x.webpacker[:dev_server_host] = "http://localhost:8080"
...
{% endhighlight %}

Теперь мы можем запустить `webpack-dev-server` c помощью команды

{% highlight bash %}
$ ./bin/webpack-dev-server
{% endhighlight %}

А Rails сервер стандартной командой

{% highlight bash %}
$ bundle exec rails s
{% endhighlight %}

Чтобы запускать оба сервера одновременно в одной вкладке можно воспользоваться утилитой <a href="https://github.com/ddollar/foreman" target="_blank">Foreman</a>. После установки необходимо создать `Procfile` c содержанием:

{% highlight ruby %}
rails: bundle exec rails s
webpack: ./bin/webpack-dev-server
{% endhighlight %}

Это позволит использовать команду `foreman s` для запуска. После чего можно открыть страницу в браузере `http://localhost:5000/main/index` на которой должен быть текст `Hello React!`.
<br>
<br>
P.S. Версии Ruby и Rails использованные в данной статье:

{% highlight bash %}
$ ruby --version
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin16]
$ rails version
Rails 5.1.0.beta1
{% endhighlight %}

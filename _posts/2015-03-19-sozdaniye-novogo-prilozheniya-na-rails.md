---
title: "Создание нового приложения на Rails"
permalink: /sozdaniye-novogo-prilozheniya-na-rails/
layout: post
date: 2015-03-19T09:21:21+03:00
---

Понял, что часто приходится создавать новое приложение Rails, решил сделать заметку с командами. По хорошему, конечно, нужно бы написать скрипт, чтобы это дело оптимизировать.  
Выбираем версию ruby
{% highlight bash %}
$ rvm use 2.2.0
{% endhighlight %}
Создаем гемсет
{% highlight bash %}
$ rvm gemset create my_app
{% endhighlight %}
переключаемся на новый гемсет
{% highlight bash %}
$ rvm gemset use my_app
{% endhighlight %}
Устанавливаем rails 
{% highlight bash %}
$ gem install rails
{% endhighlight %}
Создаем новое приложение
{% highlight bash %}
$ rails new my_app -d postgresql
{% endhighlight %}
Переходим в каталог нового приложения
{% highlight bash %}
$ cd my_app
{% endhighlight %}
Закрепляем версию руби и гемсет за данным каталогом, т.е. проектом
{% highlight bash %}
$ rvm --ruby-version use rvm current@my_app
{% endhighlight %}
сохраняем исходный конфиг database.yml и редактируем database.yml
{% highlight bash %}
$ cp config/database.yml config/database.yml.sample
{% endhighlight %}
Создаем базы
{% highlight bash %}
$ rake db:create:all
{% endhighlight %}
Ну и git
{% highlight bash %}
git init
echo config/database.yml >> .gitignore
git add .
git ci -am "initial commit"
{% endhighlight %}





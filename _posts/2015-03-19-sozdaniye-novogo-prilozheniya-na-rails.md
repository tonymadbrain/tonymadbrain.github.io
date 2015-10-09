---
title: "Создание нового приложения на Rails"
permalink: /sozdaniye-novogo-prilozheniya-na-rails/
layout: post
date: 2015-03-19T09:21:21+03:00
tags:
  - Rails
  - Rvm
---

Понял, что часто приходится создавать новое приложение Rails, решил сделать заметку с командами. По хорошему, конечно, нужно бы написать скрипт, чтобы это дело автоматизировать.

<br>
<img src="https://farm1.staticflickr.com/611/21186379074_a897e27375_o.jpg">
<br>
<br>

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
$ gem install rails --no-ri --no-rdoc
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

UPD: Скрипт я все таки сделал, но он дико заточен под меня, без параметров. Всегда создается проект с базой данных postgres и иницируется git, а также все проекты у меня лежат в каталоге ~/projects.

Сам скрипт:
{% highlight bash %}
#!/bin/bash

read -n 1 -p "Ты запустил скрипт с параметрами - x.x.x my_super_app (y/[a])?: " AMSURE
[ "$AMSURE" = "y" ] || exit
echo "" 1>&2

cd ~/projects

rubyVersion=$1
appName=$2
echo -e "\x1B[33m### Try ruby version: $rubyVersion ###\x1B[39m"
echo -e "\x1B[33m### Try application name: $appName ###\x1B[39m"

if which rvm 1>/dev/null; then
  echo -e "\x1B[32m### Using RVM ###\x1B[39m"
else
  echo -e "\x1B[31m### RVM not instaled ###\x1B[39m"
  exit
fi

rvm use $rubyVersion
rvm gemset create $appName
rvm gemset use $appName
gem install rails --no-ri --no-rdoc
echo -e "\x1B[32m### Rails done! ###\x1B[39m"
rails new $appName -d postgresql
cd $appName
rvm --ruby-version use rvm current@$appName
cp config/database.yml config/database.yml.sample

#git
git init
echo config/database.yml >> .gitignore
git add .
git ci -am "Initial commit for $appName"
echo -e "\x1B[32m### All done! ###\x1B[39m"
echo -e "\x1B[33m### Do not forget edit database.yml and create DBs with 'rake db:create:all' ###\x1B[39m"
{% endhighlight %}



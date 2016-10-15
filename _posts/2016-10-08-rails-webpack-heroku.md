---
layout: post
title: Деплоим Rails + Webpack приложение на Heroku
excerpt: ""
tags:
  - Rails
  - Heroku
  - Webpack
date: 2016-10-08T23:35:17+03:00
---

{% include _toc.html %}

<br>
<img src="https://farm6.staticflickr.com/5711/29580740974_9ddf4c9f93_o.png">
<br>
<br>

> От переводчика: <a href="http://crypt.codemancers.com/posts/2016-03-18-rails-webpack-heroku/" target="_blank">Оригинал статьи</a>

### Вступление

Деплой на Heroku Rails приложения которое использует Webpack требует некоторых хитростей, так как для этого нужны одновременно и Ruby, и Node.js. После нескольких неудачных попыток, я нашел решение которое работает без кастомизации билдпаков (buildpacks) Heroku. Если вы знаете как работают билдпаки Heroku, можете прочитать только резюме для [TL;DR версии](#section-1).
<br>
<br>
Для начала небольшая вводная. Приложение, над которым я работаю, использует `React` для отрисовки интерактивных компонентов на фронтенде. Rails обрабатывает роутинг и общается с базой данных. Компоненты React написаны на синтаксисе ES6 который *транспилируется* в более широко используемый ES5 API с помощью Babel. Также я использую ESLint и Redux. Все модули JavaScript собираются в один файл при помощи Webpack.

> Транспилер -  компилятор, транслирующий исходный код на одном языке программирования в исходный код на другом языке программирования или более раннюю версию того же языка

Стоит отметить, что есть хорошо поддерживаемый гем <a href="https://github.com/reactjs/react-rails" target="_blank">react-rails</a>, но мы выбрали `npm`, потому что хотели использовать последние версии пакетов React, Redux, ESLint и чувствовали что рабочий процесс (workflow) с npm-based управлением пакетов подойдет лучше в данном случае.
<br>
<br>
Вот структура проекта с которой мы решили работать:

{% highlight bash %}
app/
lib/
config/
... (обычные каталоги rails)
webpack/
  |-- package.json
  |-- components
  |-- reducers
{% endhighlight %}

Первоначально, `package.json` требуемый для npm был помещен в каталоге `webpack/`, но это усложнило деплой на Heroku. После компиляции Webpack весь JavaScript собирается в файле `react_bundle.js` и кладется в каталог `app/assets/javascripts`. Этот файл в свою очередь загружается через asset pipeline. Собранный файл должен лежать на своем месте до того как запустится `assets:precompile` в процессе деплоя.

### Билдпаки Heroku

Heroku использует установочные скрипты, которые они назвали <a href="https://devcenter.heroku.com/articles/buildpacks" target="_blank">buildpacks</a>, для определения типа приложения и запуска необходимых шагов для деплоя. Например, Heroku запускает сборку и деплой Rack-based приложения если видит файл `Gemfile` в корне приложения. Если при этом в списке гемов будут рельсовые то запустится сборка и деплой Rails приложения. Упрощенно, для запуска Rack приложения нужны следующие шаги:

1. Поиск `Gemfile` и `Gemfile.lock` в корневой директории. Если такие есть то предполагаем что это Ruby приложение и стартуем соответствующие задачи.
2. Проверка что в `Gemfile.lock` есть Rack.
3. Установка требуемой версии Ruby
4. Установка bundler'а и всех зависимостей
5. Запуск web сервера на основании `Procfile` или <a href="https://github.com/heroku/heroku-buildpack-ruby/blob/v146/lib/language_pack/rack.rb#L27" target="_blank">веб сервера по умолчанию</a>

Таким же образом Heroku выполняет шаги для Node.js приложений, основываясь на наличии файла `package.json` в корневой директории. Итак, что же делать если нам нужна сборка и Ruby и Node.js одновременно? Нужно чтобы и `Gemfile`, и `package.json` присутствовали в корневой директории. Это **шаг №1**.

### Множественные билдпаки Heroku

Heroku поддерживает <a href="https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app" target="_blank">множественные билдпаки</a> для одного приложения. Если у нас Node.js и Ruby билдпаки, то нужен способ указать Heroku, что сначала нужно выполнить сборку для npm и только потом запускать сборку Ruby. Это нужно для того, чтобы файл `react_bundle.js` был на своем месте в `app/assets/javascripts` до того как запустится сборка assets в Rails. Командная строка Heroku дает нам способ задавать билдпаки и указывать порядок в котором они должны запускаться:

{% highlight bash %}
heroku buildpacks:clear
heroku buildpacks:set heroku/nodejs
heroku buildpacks:add heroku/ruby --index 2
{% endhighlight %}

Аргумент `--index` означает что `heroku/ruby` билдпак добавляется *после* `heroku/nodejs`. Это завершает **шаг №2**.

### Отправка билд хука на Heroku

После того как билдпаки установлены, нам нужен способ запустить команду Webpack сразу после того как Node.js собран, но до того как будет начата сборка Ruby/Rails. Билдпак для Node.js <a href="https://devcenter.heroku.com/articles/nodejs-support#customizing-the-build-process" target="_blank">поддерживает способ</a> выполнить кастомный скрипт сразу после того как сборка Node.js прошла. Для этого команда должна быть указана в `package.json` внутри секции `scripts` c ключом `heroku-postbuild`. Вот пример актуальной секции `scripts` из `package.json`:

{% highlight JSON %}
"scripts": {
  "webpack:deploy": "webpack --config=webpack/webpack.config.js -p",
  "heroku-postbuild": "npm run webpack:deploy"
},
{% endhighlight %}

На этом заканчивается **шаг №3**. Благодаря этим 3 шагам, я смог построить работающий процесс деплоя для Rails + Webpack приложения.

### Резюме

1. Поместите `package.json` в корневом каталоге вашего Rails приложения.
2. Настройте множественные билдпаки на Heroku через утилиту командной строки так, чтобы `heroku/nodejs` был на первом месте а `heroku/ruby` втором.
3. Добавьте Webpack команду для сборки бандла в секцию `scripts` файла `package.json` с ключом `heroku-postbuild`.




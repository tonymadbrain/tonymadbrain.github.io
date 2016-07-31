---
layout: post
title: "Создаем Rails 5 API бекенд и Ember.js фронтенд c нуля"
permalink: "/how_to_build_a_rails_5_api_only_and_ember_application_from_scratch/"
redirect_from: "/2015-10-09-how_to_build_a_rails_5_api_only_and_ember_application_from_scratch/"
excerpt: ""
date: 2015-10-09T22:39:13+03:00
tags:
  - Rails
  - Ember
  - Ruby
  - Javascript
  - API
  - Tutorial
---
Эта инструкция рассказывает как создать приложение на <a href="http://rubyonrails.org/" target="_blank">Rails</a> API в качестве бекенда с <a href="http://emberjs.com/" target="_blank">Ember</a> на фронтенде c нуля. Cтатья объединяет два поста на эту тему <a href="http://wyeworks.com/blog/2015/6/30/how-to-build-a-rails-5-api-only-and-ember-application" target="_blank">первый</a> и <a href="https://devmynd.com/blog/2014-7-rails-ember-js-with-the-ember-cli-redux-part-1-the-api-and-cms-with-ruby-on-rails" target="_blank">второй</a>.

{% include _toc.html %}

<br>
<img src="https://farm2.staticflickr.com/1573/24190597350_e88e12cfd5_o.jpg">
<br>


> От переводчика: Оригинал статьи <a href="http://aviav.github.io/blog/2015/09/21/how_to_build_a_rails_5_api_only_and_ember_application_from_scratch/" target="_blank">aviav</a>

> <a href="https://github.com/rails/rails/pull/19832" target="_blank">Rails API был влит в мастер ветку Rails</a>

###Создаем бекенд

На момент написания статьи Rails 5 требует Ruby версии 2.2.2 и выше, если вы используете <a href="https://rvm.io/" target="_blank">rvm</a>, выполните `rvm install 2.2.3`, чтобы установить требуемую версию. Чтобы использовать в качестве дефолтной версии `rvm use 2.2.3 --default`.

> От переводчика: Для каждого проекта, я рекомендую создавать отдельный гемсет, дабы не испытывать проблем с зависимостями, это можно сделать по <a href="http://doam.ru/sozdaniye-novogo-prilozheniya-na-rails/" target="_blank">моей статье.</a>

Так как Rails 5 на данный момент не зарелизен, нам нужно клонировать репозиторий на Github и генерировать приложение из исходников. Для этого выполняем команды:

{% highlight bash %}
git clone git://github.com/rails/rails.git
cd rails
bundle
bundle exec railties/exe/rails new ../my_api_app --api --edge
{% endhighlight %}

> От переводчика: Лично у меня, на третьей команде возникли трудности с установкой гема nokogiri, помогла команда `gem install nokogiri -v 1.6.7rc3 --pre`.

####Генерируем ресурс пользователи

Мы сгенерируем очень простое приложение с помощью генератора rails (`rails generate scaffold`) и выполним миграции:

{% highlight bash %}
cd ../my_api_app
bin/rails g scaffold user name
bin/rake db:migrate
{% endhighlight %}

####Установим JSON формат сериализации данных

REST адаптер Ember требует чтобы root объекты были представлены в JSON. Это можно достигнуть установкой json адаптера вместо flatten_json сериалайзера Active Model.
Создаем новый файл инициализации `config/initializers/ams_json_adapter.rb` включающий следующий текст:

{% highlight ruby %}
ActiveModel::Serializer.config.adapter = :json
{% endhighlight %}

Чтобы протестировать что данные представляются в нужном формате, запустим сервер с помощью команды `bin/rails server` и создадим нового пользователя с помощью `curl`:

{% highlight bash %}
curl -H "Content-Type:application/json; charset=utf-8" \
-d '{"user": {"name":"Hans"}}' http://localhost:3000/users
{% endhighlight %}

Открыв в браузере `localhost:3000/users`, мы можем увидеть только что созданного пользователя и то что данные отображаются в формате, который мы указали.

####Установка CORS

Так как наши бекенд и фронтенд будут запускаться отдельно, нам нужно сконфигурировать Cross Origin Resource Sharing (CORS). Мы будем пробовать бекенд на localhost:3000 и фронтенд на localhost:4200. В начале, нам нужно раскомментировать `rack-cors` в Gemfile, запустить `bundle` и добавить следующий код в config/initializers/cors.rb:

{% highlight ruby %}
# Avoid CORS issues when API is called from the frontend app
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests

# Read more: https://github.com/cyu/rack-cors

 Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
   allow do
     origins 'localhost:4200'

     resource '*',
       headers: :any,
       methods: [:get, :post, :put, :patch, :delete, :options, :head]
   end
 end
{% endhighlight %}

> От переводчика: здесь и далее, я советую использовать адрес 0.0.0.0 для запуска серверов вместо localhost.

###Создаем фронтенд

Данная инструкция включает Ember приложение, которое использует простой ресурс `Users` чтобы получать данные от Rails API и показывать их на главной странице.

####Установка Ember CLI и созадние фронтенд

Для установки Ember CLI, мы используем --no-optional, так как он менее подвержен ошибкам. Используя nvm, нам не нужно запускать npm от пользователя root, это исключает проблемы прав:

{% highlight bash %}
npm install -g ember-cli --no-optional
{% endhighlight %}

Create the Ember.js app:

{% highlight bash %}
cd ..
ember new my_ember_frontend
cd my_ember_frontend
{% endhighlight %}

На момент написания статьи, даже с использованием текущей версии node.js, появляется предупреждение: `Future versions of Ember CLI will not support v4.1.0. Please update to Node 0.12 or io.js.`. Не волнуйтесь: фикс этого ошибочного сообщения анонсирован и будет добавлен в следущих версиях Ember CLI.

####Генерируем адаптер приложения

Чтобы заставить наше приложение на Ember общаться с Rails приложением, мы сгенерируем адаптер:

{% highlight bash %}
ember generate adapter application
{% endhighlight %}

Теперь отредактируем файл `app/adapters/application.js`:

{% highlight javascript %}
import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
  host: 'http://localhost:3000'
});
{% endhighlight %}

####Добавляем ресурс Users в router.js

Редактируем `app/router.js`:

{% highlight javascript %}
import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.resource('users');
});

export default Router;
{% endhighlight %}

####Генерируем модель User

Вначале,

{% highlight bash %}
ember generate model user
{% endhighlight %}

Затем редактируем `app/models/user.js`:

{% highlight javascript %}
import DS from 'ember-data';

export default DS.Model.extend({
    name: DS.attr('string')
});
{% endhighlight %}

####Генерируем маршрут Users/index

Теперь,

{% highlight bash %}
ember generate route users/index
{% endhighlight %}

Редактируем `app/routes/users/index.js`:

{% highlight javascript %}
import Ember from 'ember';

export default Ember.Route.extend({
    model: function() {
        return this.store.findAll('user');
    }
});
{% endhighlight %}

####Пишем шаблон для Users/index

Редактируем `app/templates/users/index.hbs`:

{% highlight html %}
<ul>
    { {#each model as |user|}}
    <li> { {user.name}} </li>
    { {/each}}
</ul>
{ {outlet}}
{% endhighlight %}

###Тестируем приложение

Чтобы протестировать наше приложение, запустим в директроии Rails приложения:

{% highlight bash %}
bin/rails s
{% endhighlight %}

и в каталоге Ember приложения:

{% highlight bash %}
ember serve
{% endhighlight %}

Теперь откроем в браузере страницу `localhost:4200/users` чтобы проверить работу приложения!
<br>
<br>
Большое спасибо уходит <a href="http://moritz-breit.de/" target="_blank">Moritz</a> за корректировку данного поста!

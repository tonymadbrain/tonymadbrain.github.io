---
layout: post
title: "Минималистичный стек Grape + Swagger для микросервисов на Ruby"
excerpt: Пилим микросервисы быстро и удобно
permalink: /ruby_the_grape_swagger_stack/
redirect_from: /ruby-the-grape-swagger-stack/
tags:
  - Ruby
  - Development
  - REST
  - API
  - CRUD
  - Grape
  - Swagger
  - Tutorial
date: 2015-11-24T12:00:00+03:00
---
Микросервисы сейчас очень популярны и используются в различных архитектурах и средах. Слова Ruby и микросервисы, принято связывать с великолепным минималистичным фреймворком *Sinatra*. Есть много хороших ruby микро-фреймворков, но <a href="http://www.ruby-grape.org/" target="_blank">Grape</a> вместе с <a href="http://swagger.io/swagger-ui/" target="_blank">Swagger UI</a> через гем <a href="https://github.com/ruby-grape/grape-swagger" target="_blank">swagger</a> действительно крут как быстрое, чистое и законченное решение. С <a href="https://github.com/ruby-grape/grape" target="_blank">Grape</a> + <a href="https://github.com/swagger-api/swagger-ui" target="_blank">Swagger UI</a> мы можем создавать Restful API сервис при этом имея автоматически сгенерированный GUI для тестов и отладки API.

{% include _toc.html %}

<br>
<img src="https://farm1.staticflickr.com/668/23256264136_af84046e42_o.jpg">
<br>

> От переводчика: <a href="http://www.roialty.com/ruby-the-grape-swagger-stack/" target="_blank">Оригинал статьи</a>

###Пример микросервиса с Grape и Swagger

В качестве примера в данной статье мы создадим микросервис который предоставляет Restful CRUD ресурс - заметки (notes).

> От переводчика: на этом этапе вы должны знать или хотя бы понимать что такое REST, CRUD и API

Модель **Note** будет содержать: *author*, *title*, *content*, *summary*, *timestamps*. *API* будет предоставлять классические *CRUD* действия: *create*, *read*, *update*, *delete* и *list* доступных ресурсов.

<br>

Весь код доступен в <a href="http://github.com/tonymadbrain/grape_rack_swagger_notes_app" target="_blank">публичном репозитории</a>.

###Базовая структура приложения

На данном этапе структура и содержание проекта должны соответствовать коммиту - <a href="https://github.com/tonymadbrain/grape_rack_swagger_notes_app/commit/20040afead0844d2f49a186b854c42d88be030c7" target="_blank">20040af</a>

{% highlight bash %}
├── app
│   └── core.rb
├── config.ru
├── Gemfile
└── Procfile
{% endhighlight %}

Мы будем использовать *bundle* для управления гемами и <a href="https://github.com/ddollar/foreman" target="_blank">foreman</a> для запуска приложения через команду `foreman start`. Файл `config.ru` будет подтягивать *rubygems*, *bundle*, `core.rb` и запускать приложение. `core.rb` в основном будет тянуть файлы нашего приложения: апи, модели и т.д.

###Добавляем Grape и первый экшн

На данном этапе структура и содержание проекта должны соответствовать коммиту - <a href="https://github.com/tonymadbrain/grape_rack_swagger_notes_app/commit/158fc4b38f664ae242a6c9d6fd6e0bbcc100c9db" target="_blank">158fc4b</a>

Grape - это *REST-like* *API* микро-фреймворк на *Ruby*. Он спроектирован так, что его можно запустить на *Rack* или добавить в существующее приложение например на *Rails* или *Sinatra*. Предоставляет простой *DSL* для легкой разработки *RESTful API*.

В качестве первого шага мы должны добавить *grape* гем и подключить его в нашем `config.ru`. Затем добавим каталог `api` с файлом ресурса `api/notes.rb` и экшеном `/test`. Также `./app/api/notes` должно быть подключено в файле `config.ru`.

В файле `api/notes.rb` используется Grape DSL:

{% highlight ruby %}
  version 'v1', using: :header, vendor: 'tonymadbrain'
    format :json

  resource 'notes' do

    get '/test' do
      { data: "TEST" }
    end
  end
{% endhighlight %}

Приведя все к нужному виду, можем проверить наш первый экшн, для этого запустим приложение командой:

{% highlight bash %}
foreman start
{% endhighlight %}

> От переводчика: если у вас не установлен *foreman* необходимо выполнить команду `gem install foreman`

и откроем в браузере ссылку <a href="http://localhost:5000/notes/test" target="_blank">http://localhost:5000/notes/test</a>. Мы должны увидеть следующее содержимое:

{% highlight json %}
{“data”:”TEST”}
{% endhighlight %}

###Добавляем Swagger и запускаем его через Rack

На данном этапе структура и содержание проекта должны соответствовать коммиту - <a href="https://github.com/tonymadbrain/grape_rack_swagger_notes_app/commit/8b9ec95d7b00b98095a6058e73a92698d1906c43" target="_blank">8b9ec95</a>

Swagger - это простое и мощное представление *RESTful API*, включение его как сервиса может дать вам бесплатную интерактивную документацию, клиентский *SDK* и понятность. В нашем приложении мы хотим добавить *swagger-ui*, чистый *html5* интерфейс для нашего *API*.

Сначала добавим гем <a href="https://github.com/ruby-grape/grape-swagger" target="_blank">grape-swagger</a> который включает swagger для наших ресурсов. Добавим swagger документацию в `app/api/notes.rb`:

{% highlight ruby %}
add_swagger_documentation \
  :info => {
     :title => "Notes API"
    },
   :hide_documentation_path => true,
   :mount_path => "/swagger_doc",
   :markdown => false,
   :api_version => 'v1'
{% endhighlight %}

Затем, скачаем <a href="https://github.com/swagger-api/swagger.io/blob/wordpress/tools/swagger-ui.md" target="_blank">swagger-ui</a> в новый каталог `public`. Теперь нам нужно сервить `/public/swagger-ui`, для этого добавим гем <a href="https://github.com/mperham/rack-fiber_pool/" target="_blank">rack-fiber_pool</a> и добавим конфигурацию в `config.ru`:

{% highlight ruby %}
use Rack::Static,
  :urls => ["/images", "/lib", "/js", "/css"],
  :root => "public/swagger_ui"

map '/swagger-ui' do
  run lambda { |env|
    [
      200,
      {
        'Content-Type'  => 'txt-html',
        'Cache-Control' => 'public, max-age=86400'
      },
      File.open('public/swagger_ui/index.html', File::RDONLY)
    ]
  }
end
{% endhighlight %}

В итоге проверяем API уже со Swagger по ссылке <a href="http://localhost:5000/swagger-ui" target="_blank">http://localhost:5000/swagger-ui</a>

<br>
<img src="https://farm6.staticflickr.com/5732/22882774707_c16dafeda8_o.png">
<br>

###Добавляем ActiveRecord, создаем таблицу и модель

#####ActiveRecord и его rake задачи

На данном этапе структура и содержание проекта должны соответствовать коммиту - <a href="https://github.com/tonymadbrain/grape_rack_swagger_notes_app/commit/412226fc308256069c7fb3c490b9ed476753c199" target="_blank">412226f</a>

Для добавления *ActiveRecord* в наше приложение мы можем использовать гем <a href="https://github.com/jhollinger/grape-activerecord" target="_blank">grape-activerecord</a>. Итак, вначале добавим `rake`, `mysql2` и `grape-activerecord` гемы в наш `Gemfile`. После установки (bundled) можем настроить подключение к базе данных. Простой способ добавить добрый старый `config/database.yml`.

Затем мы должны включить менеджер подключений *ActiveRecord* добавлением строки в `config.ru`:

{% highlight ruby %}
use ActiveRecord::ConnectionAdapters::ConnectionManagement
{% endhighlight %}

Добавление следующего *Rake* файла даст нам возможность использовать задачи базы данных:

{% highlight ruby %}
require "bundler/setup"
require "grape/activerecord/rake"
namespace :db do
  # Some db tasks require your app code to be loaded, or at least your gems
  task :environment do
    require_relative "app/core"
  end
end
{% endhighlight %}

Запустим `bundle exec rake -T` и увидим все доступные задачи.

#####Таблица и создание моделей

На данном этапе структура и содержание проекта должны соответствовать коммиту - <a href="https://github.com/tonymadbrain/grape_rack_swagger_notes_app/commit/8cc1a849097b5c62a8beacb2296ab7f0e74b7fdc" target="_blank">8cc1a84</a>

Давайте создадим базу данных:

{% highlight bash %}
bundle exec rake db:create
{% endhighlight %}

Теперь миграции:

{% highlight bash %}
bundle exec rake db:create_migration NAME=create_table_notes
{% endhighlight %}

{% highlight ruby %}
class CreateTableNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :author
      t.string :title
      t.text :content
      t.text :summary
      t.boolean :private, default: false
      t.integer :valuation

      t.timestamps null: false
    end
    add_index :notes, :author
  end
end
{% endhighlight %}

Теперь мы можем добавить нашу простую *ActiveRecord* модель **Note** в файле `app/models/note.rb`.

{% highlight ruby %}
class Note < ActiveRecord::Base
  validates :author, :title, :content, presence: true
end
{% endhighlight %}

###Добавляем Restful CRUD экшены в наш ресурс

На данном этапе структура и содержание проекта должны соответствовать коммиту - <a href="https://github.com/tonymadbrain/grape_rack_swagger_notes_app/commit/c4d1cdf30bdcc3d5d67d8d0540d4a6c9542c0555" target="_blank">c4d1cdf</a>

И, наконец, пришло время чтобы кодить наши *CRUD* экшены, методы *desc* и *params* передают swagger UI описание экшена и опциональные параметры с их типами и описаниями.

Создаем экшены с документацией и логикой:

{% highlight ruby %}
desc 'Create a note.'
params do
  requires :author, type: String, desc: 'Author'
  requires :title, type: String, desc: 'Title'
  requires :content, type: String, desc: 'Body'
  optional :summary, type: String, desc: 'Summary'
  optional :private, type: Boolean, desc: 'Private'
  optional :valuation, type: Integer, desc: 'Valuation'
end
post '/' do
  Note.create params
end
{% endhighlight %}

Swagger UI теперь должен показывать все экшены,

<br>
<img src="https://farm1.staticflickr.com/584/22910682059_868be6aa63_o.png">
<br>

<br>
<img src="https://farm1.staticflickr.com/590/23195984871_5ec81747f5_o.png">
<br>

###Заключение

В действительности этот пример очень простой, но он показывает как легко можно создавать микросервисы с документированным API на Ruby с помощью Grape и Swager.

Дополнительный бонус от использования Swagger это поддержка многих языков и фреймворков, мы получаем унифицированную документацию и UI для сервисов написанных на Java, Ruby, Python и т.д.

> От переводчика: В некоторых моментах я не согласен с автором, например в оригинале используется каталог app/apis, у меня же app/api; использование foreman и activerecord избыточно; отсутсвует TDD и др.


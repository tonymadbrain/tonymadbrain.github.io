---
layout: post
title: React.js - tutorial для Rails разработчиков (часть 1)
permalink: /react_js_for_rails_developers_part_1/
redirect_from: /react-js-for-rails-developers-part-1/
excerpt: Учимся работать с React в Rails
tags:
  - Ruby
  - RubyOnRails
  - React
  - Tutorial
date: 2016-01-15T08:53:14+03:00
---
React.js это новый популярный игрок из команды "Фреймворки JavaScript", и он отличается своей простотой. Там где другие фреймворки реализуют полноценный MVC, можно сказать что React реализует только V (причем многие заменяют V в своих фреймворках на React). Приложения на React строятся на двух основных принципах: *Компоненты* (Components) и *Состояния* (States). Компоненты могут быть сделаны из других компонентов поменьше, встроенных или кастомных; Состояния это, как называют его ребята из Facebook - *one-way reactive data flow*, означает что наш UI будет реагировать на каждое изменение состояния.

{% include _toc.html %}

<br>
<img src="https://farm2.staticflickr.com/1480/23858108174_a563951ceb_o.jpg">
<br>

> От переводчика: <a href="https://www.airpair.com/reactjs/posts/reactjs-a-guide-for-rails-developers" target="_blank">Оригинал статьи</a>

Одна из хороших вещей в React это то, что он не требует дополнительных зависимостей, что делает его подключаемым с практически любой JS библиотекой. Воспользовавшись этой функцией, мы собираемся включить его в наш Rails стек и построить *frontend-powered* приложение, или, если пожелаете, Rails вьюхи на стероидах.

##Макет приложения

В данной статье, мы будем создавать с нуля маленькое приложение для отслеживания затрат; каждая запись будет содержать дату, заголовок и сумму. Записи будут делиться на Кредит (Credit) если сумма больше нуля и Дебет (Debit) в обратном случае. Вот макет проекта:

<br>
<img src="https://farm2.staticflickr.com/1659/23794397494_c45a9b62a6_o.png">
<br>

Суммируя, в приложении будут следующие кейсы:

* Когда пользователь создает новую запись через горизонтальную форму, она (запись) будет добавляться в таблицу со всеми записями
* Пользователь сможет построчно редактировать любую запись
* Клик по любой кнопке *Delete* будет удалять связанную запись из таблицы
* Добавление, редактирование и удаление записей будет обновлять сумму в окне на верху страницы

##Создаем приложение

Любое приложение начинается с простых вещей. Создадим наше приложение и назовем его, например, `Accounts`:

{% highlight bash %}
rails new accounts
{% endhighlight %}

> Я рекомендую использовать RVM для управления версиями Ruby и для каждого приложения отдельный gemset, подробнее можно посмотреть в <a href="http://doam.ru/sozdaniye-novogo-prilozheniya-na-rails/" target="_blank">этой статье</a>.

Для UI нашего проекта будет использован Twitter Bootstrap. Процесс установки bootstrap немного выходит из рамок данного how-to, вы можете установить например официальный гем `bootstrap-sass` следуя <a href="https://github.com/twbs/bootstrap-sass" target="_blank">инструкции</a> или использовать <a href="https://rails-assets.org/" target="_blank">rails-assets</a>.

Когда наш проект инициализирован, нужно добавить в него React. В данной записи мы будем устанавливать официальный гем <a href="https://github.com/reactjs/react-rails" target="_blank">react-rails</a> потому что будем использовать некоторые крутые фишки, реализованные в данном геме, но есть и другие способы выполнить эту задачу, например все теже <a href="https://rails-assets.org/" target="_blank">rails-assets</a> или можно скачать исходники с <a href="https://facebook.github.io/react/" target="_blank">официальной страницы</a> и разместить их в паке `javascrips`.

Если вы до этого имели дело с Rails, то вы знаете как легко добавить гем в проект, добавим нужный нам гем `react-rails` в *Gemfile*:

{% highlight ruby %}
gem 'react-rails', '~> 1.0'
{% endhighlight %}

Затем, естественно, устанавливаем новые гемы:


{% highlight bash %}
bundle install
{% endhighlight %}

`react-rails` идет с установочным скриптом, который создаст файл `component.js` и каталог `components` в папке `app/assets/javascripts` где собственно и будут жить наши компоненты React.

{% highlight bash %}
rails g react:install
{% endhighlight %}

Если после процесса установки вы загляните в файл `application.js` то найдете там три новых линии:

{% highlight javascript %}
  //= require react
  //= require react_ujs
  //= require components
{% endhighlight %}

В основном, он включает актуальную react библиотеку, манифест `components` и `ujs`. Как вы могли догадаться для имен файлов react-rails включает ненавязчивый JavaScript драйвер, который поможет нам монтировать React компоненты и будет поддерживать события *Turbolinks*.

##Создаем ресурс

Мы создадим ресурс `Record`, который будет включать поля `date`, `title` и `amount`. Вместо использования генератора `scaffold`, мы будем использовать генератор `resource`, потому что нам не понадобятся все файлы и методы, которые создаются при исползовании `scaffold`.

{% highlight bash %}
rails g resource Record title date:date amount:float
{% endhighlight %}

Чуть чуть магии и у нас будет готовый ресурс `Record`, включающий модель, контроллер и маршруты. Остается только создать базу данных и запустить миграции.

{% highlight bash %}
rake db:create db:migrate
{% endhighlight %}

Дополнительно вы можете создать несколько записей в базе данных используя `rails console`:

{% highlight bash %}
Record.create title: 'Record 1', date: Date.today, amount: 500
Record.create title: 'Record 2', date: Date.today, amount: -100
{% endhighlight %}

Не забудьте запустить сервер с помощью команды `rails s`.
<br>
Ура! Теперь мы можем кодить.

##Вложенные компоненты: список записей

Нашей первой задачей будет рендерить любые записи в таблице. Для начала, нужно создать экшен `index` в нашем контроллере `Records`:

{% highlight ruby %}
# app/controllers/records_controller.rb

class RecordsController < ApplicationController
  def index
    @records = Record.all
  end
end
{% endhighlight %}

Далее, нам нужно создать новый файл `index.html.erb` в папке `app/views/records/`, этот файл будет мостом между нашим Rails приложением и React компонентами. Чтобы достигнуть этого мы будем использовать хелпер метод `react_component`, который получает имя компонента React, который мы хотим отрендерить вместе с данными которые мы хотим в него передать.

{% highlight ruby %}
<%# app/views/records/index.html.erb %>

  <%= react_component 'Records', { data: @records } %>
{% endhighlight %}

Стоит отметить, что этот хелпер предоставляется гемом `react-rails` и если использовать другие способы интеграции React в Rails приложение, то он не будет работать.

Теперь вы можете открыть http://localhost:3000/records в браузере. Очевидно, что сейчас ничего работать не будет, потому что у нас просто напросто нет React компонента Records, но если мы посмотрим в код сгенерированной страницы, то увидим примерно следующее:

{% highlight html %}
<div data-react-class="Records" data-react-props="{...}">
  </div>
{% endhighlight %}

C такой разметкой, `react_ujs` видит что мы пытаемся рендерить React компонент и будет инициализировать его, включая свойства, которые мы передали через `react_component`, в нашем случае содержимое `@records`.

Пришло время сделать наш первый React компонент. В каталоге `javascripts/components` создаем новый файл и называем его `records.js.coffee`, этот файл и будет содержать наш компонент Records.

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  render: ->
    React.DOM.div
      className: 'records'
      React.DOM.h2
        className: 'title'
        'Records'
{% endhighlight %}

Каждый компонент должен содержать метод `render`, который будет отвечать за рендеринг самого себя. Этот метод должен возвращать экземпляр класса ReactComponent, в этом случае, когда React выполнит ре-рендер, он (экземпляр) будет обработан оптимальным путем (React обнаруживает существование новых узлов путем создания виртуального DOM в памяти). В примере выше мы создали экзмепляр h2, встроенный ReactComponent.

> Другой способ инициализировать ReactComponents внутри метода render через `JSX` синтаксис. Пример кода выше эквивалентент следующему:

{% highlight coffeescript %}
render: ->
    `<div className="records">
      <h2 className="title"> Records </h2>
    </div>`
{% endhighlight %}

Я рекомендую, если вы работаете с soffescript, использовать синтаксис `React.DOM` вместо `JSX`, потому что код будет выстраиваться иерархично, как, например, в haml. Однако, если вы интегрируете React в существующее приложение с erb, вы можете реюзать уже существующий код конвертируя его в *JSX*.

Теперь обновим страницу в браузере.

Отлично! Мы отрендерили наш первый компонент React. Теперь настало время для отображения наших записей (records).

Кроме метода рендеринга, React компоненты имеют способность общаться между собой и сообщать свое состояние, чтобы определить необходим ре-рендеринг или нет. Нам нужно инициализировать состояния наших комопнентов и свойства с требуемыми значениями:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  getInitialState: ->
    records: @props.data
  getDefaultProps: ->
    records: []
  render: ->
    ...
{% endhighlight %}

Метод `getDefaultProps` будет выставлять свойства нашего компонента в случае, если мы забыли отправить какие-либо данные при его инициализации, и метод `getInitialState` будет генерировать начальное состояние наших компонентов. Теперь нам нужно отобразить записи предоставленные нам вьюхой Rails.

Похоже нам нужен хелпер чтобы форматировать строку с суммой (amount), мы можем написать простой форматтер строк и сделать его доступным для всех наших coffee файлов. Создадим новый файл `utils.js.coffee` в каталоге `javascripts/` со следующим содержимым:

{% highlight coffeescript %}
# app/assets/javascripts/utils.js.coffee

  @amountFormat = (amount) ->
    '$ ' + Number(amount).toLocaleString()
{% endhighlight %}

Нам нужно создать новый компонент Record чтобы отображать каждую отдельную запись, создадим новый файл `record.js.coffee` в папке `javascripts/components` и запишем в него следующий контент:


{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  render: ->
    React.DOM.tr null,
      React.DOM.td null, @props.record.date
      React.DOM.td null, @props.record.title
      React.DOM.td null, amountFormat(@props.record.amount)
{% endhighlight %}

Компонент Record будет отображать строку таблицы содержащую ячейки для каждого аттрибута записи. Не волнуйтесь об этих *null* в вызовах React.DOM.*, это означает что мы не отправляем атрибуты в компоненты. Теперь обновим метод рендер в компоненте Records следующим кодом:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  render: ->
    React.DOM.div
      className: 'records'
      React.DOM.h2
        className: 'title'
        'Records'
      React.DOM.table
        className: 'table table-bordered'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Date'
            React.DOM.th null, 'Title'
            React.DOM.th null, 'Amount'
        React.DOM.tbody null,
          for record in @state.records
            React.createElement Record, key: record.id, record: record
{% endhighlight %}

Мы создали таблицу со строкой заголовком и внутри тела таблицы мы создали элемент Record для каждой существующей записи. Другими словами, мы угнездили встроенный и кастомный React компоненеты. Круто, да?

Чтобы React не тратил много времени на обновление нашего UI, при создании элемента Record, вместе с ним мы посылаем ключ: `record.id`. Если мы так не сделаем, то увидим предупреждение в консоли браузера (и скорее всего получим головную боль в дальнейшем).

<br>
<img src="https://farm2.staticflickr.com/1628/24485535665_278d25ff67_o.png">
<br>

Вы можете посмотреть на результирующий код этой секции <a href="https://github.com/fervisa/accounts-react-rails/tree/bf1d80cf3d23a9a5e4aa48c86368262b7a7bd809" target="_blank">здесь</a> или только изменения <a href="https://github.com/fervisa/accounts-react-rails/commit/bf1d80cf3d23a9a5e4aa48c86368262b7a7bd809" target="_blank">здесь</a>.

##Родитель-Потомок коммуникация: Создание записей

Теперь когда мы отображаем все имеющиеся записи, будет неплохо добавить форму для создания новых записей, давайте добавим эту фичу в наше React/Rails приложение. В начале, нам нужно добавить метод в наш Rails контроллер (не забываем использовать `strongparams`):

{% highlight ruby %}
# app/controllers/records_controller.rb

class RecordsController < ApplicationController
  ...

  def create
    @record = Record.new(record_params)

    if @record.save
      render json: @record
    else
      render json: @record.errors, status: :unprocessable_entity
    end
  end

  private

    def record_params
      params.require(:record).permit(:title, :amount, :date)
    end
end
{% endhighlight %}

Теперь, нам нужно создать React компонент чтобы обрабатывать создание новых записей. Компонент будет иметь собственное состояние чтобы хранить дату, заголовок и стоимость. Создадим новый файл `record_form.js.coffee` в каталоге `javascript/components` со следующим кодом:

{% highlight coffeescript %}
# app/assets/javascripts/components/record_form.js.coffee

@RecordForm = React.createClass
  getInitialState: ->
    title: ''
    date: ''
    amount: ''
  render: ->
    React.DOM.form
      className: 'form-inline'
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Date'
          name: 'date'
          value: @state.date
          onChange: @handleChange
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Title'
          name: 'title'
          value: @state.title
          onChange: @handleChange
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'number'
          className: 'form-control'
          placeholder: 'Amount'
          name: 'amount'
          value: @state.amount
          onChange: @handleChange
      React.DOM.button
        type: 'submit'
        className: 'btn btn-primary'
        disabled: !@valid()
        'Create record'
{% endhighlight %}

Ничего фантастического, просто Bootstrap инлайн форма. Обратите внимание как мы объявляем атрибут `value` для установки значения инпута и атрибут `onChange` чтобы привязать метод обработчика, который будет вызываться на каждое нажатие клавиши. Метод обработчика `handleChange` будет использовать имя атрибута чтобы определить какой инпут запустил событие и обновлять соответсвтующее значение состояния:

{% highlight coffeescript %}
# app/assets/javascripts/components/record_form.js.coffee

@RecordForm = React.createClass
  ...
  handleChange: (e) ->
    name = e.target.name
    @setState "#{ name }": e.target.value
  ...
{% endhighlight %}

Мы используем интерполяцию строк чтобы динамически определять ключи объектов, эквивалент `@setState title: e.target.value` когда `name` равно `title`. Но зачем нам использовать `@setState`? Почему мы не можем просто засетить желаемое значение для `@state` как мы обычно это делаем в регулярных JS объектах? Потому что `@setState` будет выполнять 2 действия:

1. Обновлять состояния компонента
2. Запускать проверку/обновление UI на основе нового состояния

Очень важно держать это в голове каждый раз когда мы используем `state` внутри наших компонентов.

Давайте посмотрим на кнопку `submit`, в самом конце нашего метода `render`:

{% highlight coffeescript %}
# app/assets/javascripts/components/record_form.js.coffee

@RecordForm = React.createClass
  ...
  render: ->
    ...
    React.DOM.form
      ...
      React.DOM.button
        type: 'submit'
        className: 'btn btn-primary'
        disabled: !@valid()
        'Create record'
{% endhighlight %}

Мы определили атрибут `disabled` со значением `!@valid()`, что означает что мы напишем метод `valid`, который будет проверять что данные, переданные пользователем, корректные.

{% highlight coffeescript %}
# app/assets/javascripts/components/record_form.js.coffee

@RecordForm = React.createClass
  ...
  valid: ->
    @state.title && @state.date && @state.amount
  ...
{% endhighlight %}

Для простоты мы проверяем `@state` на пустые строки. Таким образом, кнопка `Create` будет включаться и выключаться в зависимости от того есть ли данные в полях.

<br>
<img src="https://farm2.staticflickr.com/1550/24704314451_7131347d71_o.png">
<br>
<img src="https://farm2.staticflickr.com/1646/24502273410_dc01ef41aa_o.png">
<br>

Теперь когда у нас есть контроллер и готова форма, время отправлять наши новые записи на сервер. Нам нужно событие для обработки формы, добавим атрибут `onSubmit` в нашу форму и `handleSubmit` метод (таким же образом мы обрабатывали событие `onChange` ранее):

{% highlight coffeescript %}
# app/assets/javascripts/components/record_form.js.coffee

@RecordForm = React.createClass
  ...
  handleSubmit: (e) ->
    e.preventDefault()
    $.post '', { record: @state }, (data) =>
      @props.handleNewRecord data
      @setState @getInitialState()
    , 'JSON'

  render: ->
    React.DOM.form
      className: 'form-inline'
      onSubmit: @handleSubmit
    ...
{% endhighlight %}

Давайте разберем новый метод построчно:

1. предотвращаем отправку html формы
2. постим (POST) данные новой записи на текущий URL
3. колбек в случае успеха (success callback)

Success callback это главная часть процесса, после успешного создания новой записи мы будем уведомлены об этом событии и `state` восстановится в свое дефолтное значение. Помните я упоминал что компоненты общаются между собой через @props? Вот, это оно. Наш текущий компонент отправляет данные обратно в родительский компонент через `@props.handleNewRecord` чтобы уведомить его о существовании новой записи.

Как вы уже догадались, везде где мы создаем элемент `RecordForm` нам нужно передавать свойство `handleNewRecord` c возвращающим методом, что-то вроде `React.createElement RecordForm, handleNewRecord: @addRecord`. У нашего родительского компонента `Records` есть состояние со всеми существующими записями, нам нужно обновить его согласно добавленной записи.

Добавим новый метод `addRecord` в файле `records.js.coffee` и создадим новый элемент `RecordForm`, сразу после заголовка h2 (внутри метода `render`)

{% highlight coffeescript %}
 # app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  addRecord: (record) ->
    records = @state.records.slice()
    records.push record
    @setState records: records
  render: ->
    React.DOM.div
      className: 'records'
      React.DOM.h2
        className: 'title'
        'Records'
      React.createElement RecordForm, handleNewRecord: @addRecord
      React.DOM.hr null
    ...
{% endhighlight %}

Обновите вкладку, заполните форму новой записью и нажмите `Create` ... Никаких задержек, запись добавилась незамедлительно и форма очистилась после сабмита, обновите страницу снова, чтобы убедиться что бекенд сохранил новые данные.

<br>
<img src="https://farm2.staticflickr.com/1656/24798391695_99584043f6_o.png">
<br>
<br>

Если вы использовали другие JS фреймворки с Rails (например AngularJS) чтобы реализовать похожие функции, вы могли столкнуться с проблемой отлупа вашего POST запроса потому что он не содержит CSRF токен, который требует Rails. Почему мы не столкнулись с этим сейчас? Все просто, мы используем `jQuery` чтобы общаться с бекендом, и `jquery_ujs` драйвер будет добавлять CSRF токен в каждый AJAX запрос за нас. Круто!

Вы можете посмотреть на результирующий код этой секции <a href="https://github.com/fervisa/accounts-react-rails/tree/f4708e19f8be929471bc0c8c2bda93f36b9a7f23" target="_blank">здесь</a> или только изменения <a href="https://github.com/fervisa/accounts-react-rails/commit/f4708e19f8be929471bc0c8c2bda93f36b9a7f23" target="_blank">здесь</a>.

##Реюзабельные компоненты: Индикаторы остатка

Какое приложение может быть без (милых) индикаторов? Давайте добавим блоки в верхней части с полезной информацией. Наша цель - показывать 3 значения: количество кредитных средств (total credit), количество дебетовых средств (total debit) и баланс (balance). Кажется что это работа для 3 компонентов или, может быть, для одного но со свойствами?

Мы можем создать новый компонент `AmountBox`, который будет получать три свойства: amount, text и type. Создадим новый файл `amount_box.js.coffee` в каталоге `javascripts/components/` со следующим содержимым:

{% highlight coffeescript %}
# app/assets/javascripts/components/amount_box.js.coffee

@AmountBox = React.createClass
  render: ->
    React.DOM.div
      className: 'col-md-4'
      React.DOM.div
        className: "panel panel-#{ @props.type }"
        React.DOM.div
          className: 'panel-heading'
          @props.text
        React.DOM.div
          className: 'panel-body'
          amountFormat(@props.amount)
{% endhighlight %}

Мы используем элемент Bootstrap - панель, чтобы отображать инфорамцию блоками и установливать цвет через свойство `type`. Мы также добавили простой форматтер - amountFormat, который читает свойство `amount` и отображает его в формате валюты.


По хорошему, чтобы иметь законченное решение, нам нужно создать такой элемент (3 раза) внутри нашего основного компонента и отправлять в него требуемые свойства в зависимости от того что мы хотим отобразить. Давайте сначала сделаем метод калькулятор, откроем компонент `Records` и добавим следующие методы:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  credits: ->
    credits = @state.records.filter (val) -> val.amount >= 0
    credits.reduce ((prev, curr) ->
      prev + parseFloat(curr.amount)
    ), 0
  debits: ->
    debits = @state.records.filter (val) -> val.amount < 0
    debits.reduce ((prev, curr) ->
      prev + parseFloat(curr.amount)
    ), 0
  balance: ->
    @debits() + @credits()
  ...
{% endhighlight %}

`credits` суммирует все записи со значением больше 0, `debits` - суммирует все записи со значением меньше нуля и `balance` говорит сам за себя. Теперь, когда методы вычислители на месте, нам просто нужно создать элементы `AmountBox` внутри метода `render` (сразу над компонентом `RecordForm`)

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  render: ->
    React.DOM.div
      className: 'records'
      React.DOM.h2
        className: 'title'
        'Records'
      React.DOM.div
        className: 'row'
        React.createElement AmountBox, type: 'success', amount: @credits(), text: 'Credit'
        React.createElement AmountBox, type: 'danger', amount: @debits(), text: 'Debit'
        React.createElement AmountBox, type: 'info', amount: @balance(), text: 'Balance'
      React.createElement RecordForm, handleNewRecord: @addRecord
  ...
{% endhighlight %}

Мы закончили с этой фишкой! Обновите страницу в браузере, вы должны увидеть три блока, отобаржющие суммы, которые мы вычислили ранее. Но погодите! Есть еще кое-что! Добавьте новую запись и посмотрите что произойдет...

<br>
<img src="https://farm2.staticflickr.com/1636/24300077614_84ea4aec71_o.png">
<br>
<br>

Вы можете посмотреть на результирующий код этой секции <a href="https://github.com/fervisa/accounts-react-rails/tree/8d6f0a4fb62f2a9abd5d34d502461388863302cb" target="_blank">здесь</a> или только изменения <a href="https://github.com/fervisa/accounts-react-rails/commit/8d6f0a4fb62f2a9abd5d34d502461388863302cb" target="_blank">здесь</a>.

##Вместо заключения

Так как материал получается довольно объемным, я решил разделить его на две части и это первая:

1. <a href="http://doam.ru/react-js-for-rails-developers-part-1/" target="_blank">React.js - tutorial для Rails разработчиков (часть 1)</a>
2. <a href="http://doam.ru/react-js-for-rails-developers-part-2/" target="_blank">React.js - tutorial для Rails разработчиков (часть 2)</a>

Вторая часть будет про `setState/replaceState`, удаление и редактирование записей, рефакторинг и `Reactive Data Flow`.

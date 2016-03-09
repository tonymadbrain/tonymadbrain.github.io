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

Это весь сервер-сайд код, который нам потребуется для нашей фичи. Теперь добавим колонку *Actions* в заголовок таблицы в нашем `React` компоненте `Records`:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  render: ->
    ...
    # almost at the bottom of the render method
    React.DOM.table
      React.DOM.thead null,
        React.DOM.tr null,
          React.DOM.th null, 'Date'
          React.DOM.th null, 'Title'
          React.DOM.th null, 'Amount'
          React.DOM.th null, 'Actions'
      React.DOM.tbody null,
        for record in @state.records
          React.createElement Record, key: record.id, record: record
{% endhighlight %}

И в заключение, откроем компоненет `Record` и добавим колонку с ссылкой `Delete`:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  render: ->
    React.DOM.tr null,
      React.DOM.td null, @props.record.date
      React.DOM.td null, @props.record.title
      React.DOM.td null, amountFormat(@props.record.amount)
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-danger'
          'Delete'
{% endhighlight %}

Сохраняем изменения, обновляем вкладку в браузере и ... У нас есть бесполезная кнопка за которой не закреплены ни какие события!

<br>
<img src="https://farm2.staticflickr.com/1698/25629234285_bef72cac73_o.png">
<br>
<br>

Давайте добавим немного функциональности. На примере компонента `RecordForm` мы уже знаем путь:

1. Обнаруживаем событие внутри потомка комопнента `Record` (onClick)
2. Выпоняем действие (отправляем DELETE запрос на сервер, в данном случае)
3. Уведомляем родительский компонент `Records` о данном событии (отправляем/получаем метод обработчик через `props`)
4. Обновляем состояние (state) компонентов `Records`

Чтобы выполнить шаг 1, мы добавим обработчик для `onClick` в `Record` тем же путем, которым мы добавили обработчик `onSubmit` для `RecordForm` чтобы создавать новые записи. К счастью для нас, `React` реализует большинство событий браузера нормальным способом, так что нам не нужно беспокоитсья о кроссбраузерной совместимости (вы можете посмотреть на полный список событий <a href="http://facebook.github.io/react/docs/events.html#supported-events">здесь</a>).

Добавим новый метод `handleDelete` и атрибут `onClick` для наших, пока что, побесполезных кнопок удаления в компоненете `Record`:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  handleDelete: (e) ->
    e.preventDefault()
    # yeah... jQuery doesn't have a $.delete shortcut method
    $.ajax
      method: 'DELETE'
      url: "/records/#{ @props.record.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteRecord @props.record
  render: ->
    React.DOM.tr null,
      React.DOM.td null, @props.record.date
      React.DOM.td null, @props.record.title
      React.DOM.td null, amountFormat(@props.record.amount)
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-danger'
          onClick: @handleDelete
          'Delete'
{% endhighlight %}

При клике на кнопку удаления, `handleDelete` отправляет *AJAX* запрос на сервер для удаления записи на бекенде и, после этого, уведомляет родительский компонент о данном событии через обработчик `handleDeleteRecord` доступный через `props`, это значит что мы должны настроить создание элементов `Record` в компоненте родителе таким образом, чтобы оно включало дополнительное свойство `handleDeleteRecor` и также реализовать актуальный обработчик метода в родителе:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  deleteRecord: (record) ->
    records = @state.records.slice()
    index = records.indexOf record
    records.splice index, 1
    @replaceState records: records
  render: ->
    ...
    # almost at the bottom of the render method
    React.DOM.table
      React.DOM.thead null,
        React.DOM.tr null,
          React.DOM.th null, 'Date'
          React.DOM.th null, 'Title'
          React.DOM.th null, 'Amount'
          React.DOM.th null, 'Actions'
      React.DOM.tbody null,
        for record in @state.records
          React.createElement Record, key: record.id, record: record, handleDeleteRecord: @deleteRecord
{% endhighlight %}

В основном, наш метод `deleteRecord` копирует текущее состояние (state) `records`, делает индексный поиск записи, которую необходимо удалить, выкидывает её из массива и обновляет состояние компонента, стандартные `JavaScript` операции.

Мы узнали о новом способе работать с состоянием (state), `replaceState`; основная разница между `setState` и `replaceState` в том, что первый обновляет только один ключ в состоянии объекта, второй же полностью **перезаписывает** текущее состояние компонента любым новым объектом, который мы отправим.

После изменения последнего куска кода, обновите вкладку в браузере и попробуйте удалить запись, несколько вещей должны произойти:

1. Запись должна исчезнуть из таблицы и ...
2. Индикаторы должны обновить количество самостоятельно, ни какой дополнительный код не нужен

<br>
<img src="https://farm2.staticflickr.com/1675/25536571451_66b2165d6b_o.png">
<br>
<br>

Мы почти закончили с нашим приложением, но прежде чем имплементировать последнюю функцию, мы можем немного отрефакторить код и, в то же время, изучить новые функции `React`


Вы можете посмотреть на результирующий код этой секции <a href="https://github.com/fervisa/accounts-react-rails/tree/1a4dc646e53fecebc821c709347aae774e9ef170" target="_blank">здесь</a> или только изменения <a href="https://github.com/fervisa/accounts-react-rails/commit/1a4dc646e53fecebc821c709347aae774e9ef170" target="_blank">здесь</a>.

##Рефакторинг: Хелперы состояний

На данный момент, у нас есть пачка методов в которых состояния обновляются без каких-либо сложностей, так как наши данные сложно назвать сложными. Но подумайте о более сложном приложении с многоуровневыми JSON состояниями, представьте себя делающего большое количество копий и жонглирующего состояними данных. React включает несколько чудных хелперов состояний нам в помощь. Неважно как глубоко (вложено) состояния, хелперы позволят манипулировать ими (состояними) с большой свободой, используя аналог языка запросов MongoDB (по крайней мере вот что <a href="https://facebook.github.io/react/docs/update.html">говорит документация React</a> ).

Перед тем как использовать хелперы, нам нужно сконфигурировать наше Rails приложение чтобы подключить их. Откройте `config/application.rb` и добавьте `config.react.addons = true` в самом низу блока `Application`:

{% highlight ruby %}
# config/application.rb

  ...
  module Accounts
    class Application < Rails::Application
      ...
      config.react.addons = true
    end
  end
{% endhighlight %}

Чтобы изменения применились, перезапустите rails сервер. ПОВТОРЯЮ, **перезапустите (restart) ваш rails сервер**. Теперь у нас есть доступ к хелперам состояний через `React.addons.update` который будет обрабатывать наш объект состояния (или любой другой объект, который мы в него отправим) и применять предоставленные команды. Мы будем использовать две команды: `$push` и `$splice` (Я заимствовал описание этих команд из <a href="https://facebook.github.io/react/docs/update.html#available-commands">официальной документации React</a>):

* {$push: array} выполняет функцию push() для всех элементов целевого массива.
* {$splice: array of arrays} для каждого элемента в arrays вызывает splice() с переданными параметрами.

Мы попробуем упростить методы `addRecord` и `deleteRecord` в компоненте `Record` используя эти хелперы, примерно вот так:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

@Records = React.createClass
  ...
  addRecord: (record) ->
    records = React.addons.update(@state.records, { $push: [record] })
    @setState records: records
  deleteRecord: (record) ->
    index = @state.records.indexOf record
    records = React.addons.update(@state.records, { $splice: [[index, 1]] })
    @replaceState records: records
{% endhighlight %}

Короче, более элегантно и с тем же результатом, обновите вкладку с приложением в браузере и проверьте, что ничего не сломалось.

Вы можете посмотреть на результирующий код этой секции <a href="https://github.com/fervisa/accounts-react-rails/tree/d19127f40ae2f795a30b7de6470cde95d3734eee" target="_blank">здесь</a> или только изменения <a href="https://github.com/fervisa/accounts-react-rails/commit/d19127f40ae2f795a30b7de6470cde95d3734eee" target="_blank">здесь</a>.

##Reactive Data Flow: Редактирование записей

Для финальной функциональности, мы добавим кнопку `Edit` рядом с каждой кнопкой `Delete` в нашей таблице записей. Когда эта кнопка будет нажата, строка с записью будет переключена из режима read-only (wink wink) в состояние редактирования, появится строчная форма, в которой пользователь сможет обновить содержимое полей записи. После отправки изменений или их отмены, строка с записью вернется в исходное состояние read-only.

Как вы могли догадаться из предыдщуего параграфа, нам нужно обрабатывать изменение данных чтобы переключать состояние каждой записи внутри нашего компонента `Record`. Это юзкейс для штуки, которая в React называется *reactive data flow*. Давайте добавим флаг `edit` и метод `handleToggle` в наш `record.js.coffee`:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  getInitialState: ->
    edit: false
  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit
  ...
{% endhighlight %}

Флаг `edit` по умолчанию будет `false` и `handleToggle` будет менять его с `false` на `true` и наоборот, нам нужно просто тригерить его по событию `onClick`.

Теперь, нам нужно держать две версии строки (read-only и form) и отображать только одну из них, в зависимости от флага `edit`. К счастью для нас, до тех пор, пока наш метод `render` возвращает `React` элемент, мы свободо можем производить любые действия с ним; мы можем определить пару хелперов `recordRow` и `recordForm` и вызывать их внутри рендера в зависимости от содержимого `@state.edit.`.

У нас уже есть начальная версия `recordRow`, это наш текущий метод `render`. Давайте перенесем его в наш абсолютно новый (brand new) метод `recordRow` и добавим новый код:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  ...
  recordRow: ->
    React.DOM.tr null,
      React.DOM.td null, @props.record.date
      React.DOM.td null, @props.record.title
      React.DOM.td null, amountFormat(@props.record.amount)
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-default'
          onClick: @handleToggle
          'Edit'
        React.DOM.a
          className: 'btn btn-danger'
          onClick: @handleDelete
          'Delete'
  ...
{% endhighlight %}

Мы добавили `React.DOM.a` элемент, который ждет события `onClick` и вызывает `handleToggle`.

Забегая вперед, у реализации `recordForm` будет похожая структура, но с `imput` полями в каждой ячейке. Мы будет использовать аттрибут `ref` для наших инпутов чтобы сделать их доступными; так как этот компоненет не обрабатывает *state*, этот новый атрибут позволит нашему компоненту читать данные, предоставляемые пользователем через `@refs`:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  ...
  recordForm: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.record.date
          ref: 'date'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.record.title
          ref: 'title'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'number'
          defaultValue: @props.record.amount
          ref: 'amount'
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-default'
          onClick: @handleEdit
          'Update'
        React.DOM.a
          className: 'btn btn-danger'
          onClick: @handleToggle
          'Cancel'
  ...
{% endhighlight %}

Этот метод может выглядить большим, хотя мы и используем HAML-like синтаксис, не пугайтесь. Заметьте, мы вызываем `@handleEdit` когда пользователь кликает на кнопку `Update`, здесь используется механизм похожий на нашу реализацию кнопки удаления.

Вы заметили разницу в том, как создаются `React.DOM.input`? Мы используем `defaultValue`вместо `value` чтобы установить начальные значения в инпуты. Это сделано, потому, что **использование просто `value` без `onChange` будет создавать read-only инпуты.**

В итоге, метод `render` сводится к следующему коду:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

  @Record = React.createClass
    ...
    render: ->
      if @state.edit
        @recordForm()
      else
        @recordRow()
{% endhighlight %}

Вы можете обновить вкладку браузера и поиграться с новым поведением кнопки редактирования, но не отправляйте никакие изменения, так как мы еще не реализовали собственно функционал обновления.

<br>
<img src="https://farm2.staticflickr.com/1455/25261685189_95db1b6c88_o.png">
<br>
<br>

Чтобы обрабатывать обновление записей, нам нужно добавить метод `update` в наш rails контроллер:

{% highlight ruby %}
# app/controllers/records_controller.rb

class RecordsController < ApplicationController
  ...
  def update
    @record = Record.find(params[:id])
    if @record.update(record_params)
      render json: @record
    else
      render json: @record.errors, status: :unprocessable_entity
    end
  end
  ...
end
{% endhighlight %}

Вернемся к нашему компоненту `Record`, нам нужно имплементировать метод `handleEdit`, который будет отправлять `AJAX` запрос на сервер с информацией об обновленной записи, затем он должен уведомить родительский компонент через отправку обновленной версии записи через метод `handleEditRecord`, который будет получен через `@props`, такую же схему мы использовали до этого когда удаляли записи:

{% highlight coffeescript %}
# app/assets/javascripts/components/record.js.coffee

@Record = React.createClass
  ...
  handleEdit: (e) ->
    e.preventDefault()
    data =
      title: React.findDOMNode(@refs.title).value
      date: React.findDOMNode(@refs.date).value
      amount: React.findDOMNode(@refs.amount).value
    # jQuery doesn't have a $.put shortcut method either
    $.ajax
      method: 'PUT'
      url: "/records/#{ @props.record.id }"
      dataType: 'JSON'
      data:
        record: data
      success: (data) =>
        @setState edit: false
        @props.handleEditRecord @props.record, data
  ...
{% endhighlight %}

Ради простоты, мы не проверяем (валидируем) пользовательские данные, просто читаем их через `React.findDOMNode(@refs.fieldName).value` и отправляем на бекенд. Изменение состояния чтобы переключить режим `edit` в случае успеха необязательно, но пользователь скажет спасибо за это.

Последнее, но не менее важное, нам нужно обновить состояние компоненета `Records` чтобы перезаписать бывшую запись, записью с новыми данными и дать реакту показать свою магию. Реализация может выглядеть так:

{% highlight coffeescript %}
# app/assets/javascripts/components/records.js.coffee

  @Records = React.createClass
    ...
    updateRecord: (record, data) ->
      index = @state.records.indexOf record
      records = React.addons.update(@state.records, { $splice: [[index, 1, data]] })
      @replaceState records: records
    ...
    render: ->
      ...
      # almost at the bottom of the render method
      React.DOM.table
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Date'
            React.DOM.th null, 'Title'
            React.DOM.th null, 'Amount'
            React.DOM.th null, 'Actions'
        React.DOM.tbody null,
          for record in @state.records
            React.createElement Record, key: record.id, record: record, handleDeleteRecord: @deleteRecord, handleEditRecord: @updateRecord
{% endhighlight %}

Как мы выучили в предыдущей секции, использование `React.addons.update` чтобы изменять состояние может выводить на более конкретные методы. Финальная связь между `Record` и `Records` это метод `@updateRecord` установленный через свойство `handleEditRecord`.

Обновите вкладку еще разок и попробуйте обновить какую-нибудь существующую запись, заметьте как блоки количества отслеживают изменения каждой записи.

<br>
<img src="https://farm2.staticflickr.com/1616/25002541273_21a013f994_o.png">
<br>
<br>

Мы закончили! Улыбнитесь, мы только что создали маленькое Rails + React приложение с нуля!

Вы можете посмотреть на результирующий код этой секции <a href="https://github.com/fervisa/accounts-react-rails/tree/1a62dd0e48b31aa55659e0035e754cee1776aa61" target="_blank">здесь</a> или только изменения <a href="https://github.com/fervisa/accounts-react-rails/commit/1a62dd0e48b31aa55659e0035e754cee1776aa61" target="_blank">здесь</a>.

##Заключение: Простота и гибкость React.js

Мы изучили некоторые функции React и едва ли выучили какие-то новые концепции. Я слышал как люди говорили - JavaScript фреймворк X или Y имеет крутую кривую обучения ...

> От переводчика: видимо имеется ввиду усложнение изучения за счет новых функций реализованных во фреймворке.

... включая введение во все новые концепции, в случае с `React` это не так; он реализует ядро *JavaScript* концепции, таких как обработка событий (event handlers) и биндинги (bindings), упрощая адоптацию и изучение. Опять же, один из плюсов его простота.

Мы также на примере научились интегрировать `React` в `Rails assets pipeline` и разобрались как использовать его вместе с CoffeeScript, jQuery, Turbolinks и остальными частями Rails. Но это не единственный способ достигнуть желаемого результата. Например, если вы не используете `Turbolinks` (следовательно, вам не нужен `react_ujs`) вы можете юзать `Rails Assets` вместо гема `react-rails`, можете использовать `Jbuilder` чтобы создавать более сложные JSON ответы; вы по-прежнему сможете получить такие же замечательные результаты.

React определенно улучшит возможности вашего фронтенда, позволяя иметь крутую библиотеку в вашем Rails стеке.














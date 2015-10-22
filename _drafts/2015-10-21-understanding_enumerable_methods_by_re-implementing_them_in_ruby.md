---
layout: post
title: "Понимание методов Enumerable методом реализации их на Ruby"
tags:
  - Ruby
  - Enumerable
  - Tutorial
date: 2015-10-21T17:26:45+03:00
---

<a href="http://ruby-doc.org/core-2.2.3/Enumerable.html" target="_blank">Enumerable</a> в Руби является, безусловно, одним из самых лучших примеров как нужно делать модули. Он предоставляет большой набор методов, полезных для обработки структур данных и требуют от вас реализовать только один метод - `each`. Так, для любого класса, который будет вести себя как коллекция и реализовывать метод `each`, может быть использован `Enumerable`.

Хороший способ понять как `Enumerable` работает - реализовать его основные методы. Реализовывая каждый метод самостоятельно, мы лучше понимаем, что каждый из них делает и как можно построить такую функциональность, которая требует реализации только одного метода.

Во-первых, нам нужен класс, который будет включать наш собственный модуль `CustomEnumerable`, давайте определим его:

{% highlight ruby %}
class ArrayWrapper

  include CustomEnumerable

  def initialize(*items)
    @items = items.flatten
  end

  def each(&block)
    @items.each(&block)
    self
  end

  def ==(other)
    @items == other
  end

end
{% endhighlight %}

Здесь не так много кода, инклудим `CustomEnumerable` (нашу собственную реализацию `Enumerable`) и пишем враппер для Array. Также реализован метод `==`, который необязателен для функциональности `Enumerable`, но нужен нам чтобы легче использовать матчеры Rspec.

###Map

В документации про `map` написано:

> Возвращает новый массив с результатами выполнения блока для каждого элемента в исходном массиве.

Итак, наш код должен вызывать переданный блок кода на каждом элементе коллекции и затем генерировать новый массив с результатом выполнения каждого вызова. Давайте реализуем это:

{% highlight ruby %}
module CustomEnumerable

  def map(&block)
    result = []
    each do |element|
      result << block.call(element)
    end
    result
  end

end
{% endhighlight %}

Это будет шаблон почти для всех методов, которые мы создаем: создаем целевой массив, вызываем метод `each` и делаем нужную работу. Важно знать, что наша реализация ничего не знает о том где будет включена (included), ожидается только, что у объекта будет метод `each`.

Чтобы увидеть `map` в действии давайте умножим каждый элемент массива на 2:

{% highlight ruby %}
it 'maps the numbers multiplying them by 2' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.map do |n|
    n * 2
  end

  expect(result).to eq([2, 4, 6, 8])
end
{% endhighlight %}

###Find

Вот что говорит документация о `find`:

> Помещает каждую запись массива в блок. Возвращает первое вхождение для которого блок не false. Если ни один объект не подошел вызывается переменная ifnone, если она не задана возвращается nil.


`find` используется чтобы искать объекты в `Enumerable` совпадающие с блоком, переданным в метод, давайте реализуем его:

{% highlight ruby %}
def find(ifnone = nil, &block)
  result = nil
  found = false
  each do |element|
    if block.call(element)
      result = element
      found = true
      break
    end
  end
  found ? result : ifnone && ifnone.call
end
{% endhighlight %}









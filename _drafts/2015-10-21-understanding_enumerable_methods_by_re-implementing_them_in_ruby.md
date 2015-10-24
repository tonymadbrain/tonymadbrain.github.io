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

> От переводчика: <a href="http://mauricio.github.io/2015/01/12/implementing-enumerable-in-ruby.html" target="_blank">Оригинал статьи</a>

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

###map

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

###find

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

Вначале мы устанавливаем переменные, в одну мы сохраним результат, если он будет, а другая нужна в качестве сигнала, если мы действительно найдем значение. Почему бы просто не использовать переменную `result` со значением `nil` если мы ничего не нашли? Потому что `nil` может быть тем самым значением, которое ищет пользователь!

Итак, нам действительно нужно знать нашли мы что-то (неважно что это) или нет до того как будем возвращать результат. И если мы ничего не нашли то вызываем результат `ifnone`, если `ifnone` - `nil` просто вернем его.

Есть много вариантов использования для `find`, например мы можем искать элемент массива:

{% highlight ruby %}
it 'finds the item given a predicate' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.find do |element|
    element == 3
  end

  expect(result).to eq(3)
end
{% endhighlight %}

Мы можем изменить значение по-умолчанию если результат не найден:

{% highlight ruby %}
it 'returns the ifnone value if no item is found' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.find(lambda {0}) do |element|
    element < 1
  end
  expect(result).to eq(0)
end
{% endhighlight %}

Это полезно если вы всегда хотите возвращать какое-то значение, даже если ничего не нашлось.

> От переводчика: в случае выше, мы возвращаем ноль, если ничего не нашлось, вместо дефолтного nil.

Ну и в простых случаях всегда можно оставить дефолтное значение:

{% highlight ruby %}
it "returns nil if it can't find anything" do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.find do |element|
    element == 10
  end
  expect(result).to be_nil
end
{% endhighlight %}

Все отлично, `find` возвращает первое совпадение в коллекции, но что если я хочу найти вернуть все значения внутри `Enumerable` удовлетворяющие критериям? Нам нужно использовать метод `find_all`!

###find_all

Снова обратимся к документации:

> Возвращает массив, содержащий все элементы из перечисления для которых переданный блок возвращает значение `true`

Итак, теперь у нас нет значений по-умолчанию, метод всегда возвращает массив всех объектов для которых выполняется переданный в блоке код (или пустой массив в случае когда совпадений нет), давайте сделаем это:

{% highlight ruby %}
def find_all(&block)
  result = []
  each do |element|
    if block.call(element)
      result << element
    end
  end
  result
end
{% endhighlight %}

Поскольку `find` выходит сразу же как только найдется результат, мы не можем использовать его в данном случае, наш метод `find_all` должен быть написан с нуля. Мы создаем массив, проходим по нашему перечислению, проверяя каждый элемент и если элемент подходит, добавляем его в массив с результатами, по окончанию мы возвращаем коллекцию с объектами, которые совпадают.

Давайте посмотрим на несколько примеров:

{% highlight ruby %}
it 'finds all the numbers that are greater than 2' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.find_all do |element|
    element > 2
  end
  expect(result).to eq([3,4])
end

it 'does not find anything' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.find_all do |element|
    element > 4
  end
  expect(result).to be_empty
end
{% endhighlight %}

Даже если совпадений не будет, код вернет массив (хоть и пустой), так что при использовании `find_all` нужно не забывать проверять что массив имеет объекты или нет (вместо проверки на nil, как это было сделано в `find`).

###reduce

`reduce` или `inject` (также известный как `foldLeft` в других языках как OCaml или Scala) это метод который применяет функцию к аккумулятору и элементу внутри `Enumerable` и производит объект аккумулятор в конце выполнения. Данная формулировка звучит странно, но, тем не менее, это очень полезная вещь когда вам нужно выполнить функцию, которая *объединяет* данные внутри коллекции.

Давайте посмотрим в документацию:

> Комбинирует все элементы в `enum`, применяя бинарную операцию, переданную в виде блока или символа в метод.

> Если в метод передается блок кода, то для каждого элемента перечисления

If you specify a block, then for each element in enum the block is passed an accumulator value (memo) and the element. If you specify a symbol instead, then each element in the collection will be passed to the named method of memo. In either case, the result becomes the new value for memo.
At the end of the iteration, the final value of memo is the return value for the method.































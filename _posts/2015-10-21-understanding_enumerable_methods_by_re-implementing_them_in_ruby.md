---
layout: post
title: "Понимание методов Enumerable методом реализации их на Ruby"
excerpt: Разбираемся что к чему
permalink: /understanding_enumerable_methods_by_re-implementing_them_in_ruby/
tags:
  - Ruby
  - Enumerable
  - Tutorial
date: 2015-10-21T17:26:45+03:00
---
<a href="http://ruby-doc.org/core-2.2.3/Enumerable.html" target="_blank">Enumerable</a> в Руби является, безусловно, одним из самых лучших примеров как нужно делать модули. Он предоставляет большой набор методов, полезных для обработки структур данных и требуют от вас реализовать только один метод - `each`. Так, для любого класса, который будет вести себя как коллекция и реализовывать метод `each`, может быть использован *Enumerable*.

{% include _toc.html %}

> От переводчика: <a href="http://mauricio.github.io/2015/01/12/implementing-enumerable-in-ruby.html" target="_blank">Оригинал статьи</a>

Хороший способ понять как *Enumerable* работает - реализовать его основные методы. Реализовывая каждый метод самостоятельно, мы лучше понимаем, что каждый из них делает и как можно построить такую функциональность, которая требует реализации только одного метода.

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

Здесь не так много кода, инклудим `CustomEnumerable` (нашу собственную реализацию *Enumerable*) и пишем враппер для Array. Также реализован метод `==`, который необязателен для функциональности *Enumerable*, но нужен нам чтобы легче использовать матчеры Rspec.

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


`find` используется чтобы искать объекты в *Enumerable* совпадающие с блоком, переданным в метод, давайте реализуем его:

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

Все отлично, `find` возвращает первое совпадение в коллекции, но что если я хочу найти вернуть все значения внутри *Enumerable* удовлетворяющие критериям? Нам нужно использовать метод `find_all`!

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

`reduce` или `inject` (также известный как `foldLeft` в других языках как OCaml или Scala) это метод который обрабатывает элементы *enum* применяя к ним блок, принимающий два параметра - аккумулятор (memo) и обрабатываемый элемент. На каждом шаге аккумулятору *memo* присваивается значение, возвращенное блоком. Первая форма позволяет присвоить аккумулятору некоторое исходное значение. Вторая форма в качестве исходного значения аккумулятора использует первый элемент коллекции (пропуская этот элемент при проходе). Хоть и звучит странно, это очень полезная функция.

Давайте посмотрим в документацию:

> Комбинирует все элементы в *enum*, применяя бинарную операцию, переданную в виде блока или символа в метод.

> If you specify a block, then for each element in enum the block is passed an accumulator value (memo) and the element. If you specify a symbol instead, then each element in the collection will be passed to the named method of memo. In either case, the result becomes the new value for memo. At the end of the iteration, the final value of memo is the return value for the method.

> Если явно не указано начальное значение для *memo*, то первый элемент коллекции используется в качестве начального значения *memo*.

Таким образом, мы должны получить блок или символ и мы можем получить начальное значение, если оно не передано, то в качестве начального значения будет использоваться первый элемент. Эта реализация на самом будет немного сложнее, давайте начнем с простого случая когда мы передаем в метод и блок и начальное значение:

{% highlight ruby %}
def reduce(accumulator, &block)
  each do |element|
    accumulator = block.call(accumulator, element)
  end
  accumulator
end
{% endhighlight %}

Итак, это довольно просто, мы вызываем блок с аккумлятором и элементом и следующий аккумулятор это производная вызова блока. Довольно простая реализация, но эта абстракция невероятно мощная и доступна во всех функциональных языках программирования для аггрегации (reduce в данном случае, это часть парадигмы map-reduce).

Давайте посмотрим на пример:

{% highlight ruby %}
it 'sums all numbers' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.reduce(0) do |accumulator,element|
    accumulator + element
  end
  expect(result).to eq(10)
end
{% endhighlight %}

И в примере у нас простая reduce функция, которая производит сложение всех элементов. Также важно проверить случай, когда *enum* пустой, если это так, функция должна вернуть начальное значение:

{% highlight ruby %}
it 'returns the accumulator if no value was provided' do
  items = ArrayWrapper.new
  result = items.reduce(50) do |accumulator,element|
   accumulator + element
  end
  expect(result).to eq(50)
end
{% endhighlight %}

Теперь, давайте добавим первый опциональный параметр, символ операции который применяется вместо блока.

{% highlight ruby %}
def reduce(accumulator, operation = nil, &block)
  if operation && block
    raise ArgumentError, "you must provide either an operation symbol or a block, not both"
  end

  block = case operation
    when Symbol
      lambda { |acc,value| acc.send(operation, value) }
    when nil
      block
    else
      raise ArgumentError, "the operation provided must be a symbol"
  end

  each do |element|
    accumulator = block.call(accumulator, element)
  end
  accumulator
end
{% endhighlight %}

Фактически реализация особо не поменялась, мы добавили проверку которая исключает случаи передачи в метод лишнего, так как должен быть передан либо символ операции либо блок. Далее мы определяем блок, если в `operation` передан символ то используем его, если там `nil` то присваим блок в `block` иначе вызываем ошибку. Основная петля (loop - т.е. проход по элементам перечисления) по факту не изменилась.

Теперь посмотрим на использование:

{% highlight ruby %}
it 'executes the operation provided' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.reduce(0, :+)
  expect(result).to eq(10)
end
{% endhighlight %}

Первое - базовое использование, вызов `reduce` с символом, который применяется к аккумулятору и каждому значению. Это тот же самый пример что и для нашей первой реализации `reduce`, но теперь используется меньше кода.

Теперь давайте посмотри на ошибочные варианты, во-первых передадим в метод и оператор и блок:

{% highlight ruby %}
it "fails if both a symbol and a block are provided" do
  items = ArrayWrapper.new(1, 2, 3, 4)
  expect do
    items.reduce(0, :+) do |accumulator,element|
      accumulator + element
    end
  end.to raise_error(ArgumentError, "you must provide either an operation symbol or a block, not both")
end
{% endhighlight %}

Когда переданы оба параметра, мы должны выдать ошибку, потому что непонятно что хочет пользователь. Тоже если то, что передано в `operation` не является символом.

{% highlight ruby %}
it 'fails if the operation provided is not a symbol' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  expect do
    items.reduce(0, '+')
  end.to raise_error(ArgumentError, "the operation provided must be a symbol")
end
{% endhighlight %}

Не `Symbol`? Извини, не могу это использовать.
</br>
Теперь, последний шаг нашей реализации - параметр аккумулятор теперь опциональный. Если его нет, должен быть использован первый элемент коллекции. Теперь у нас есть 4 варианта использования `reduce`:

* `accumulator` + блок кода
* `accumulator` + `operation`
* `operation`
* без параметро + блок

Давайте сделаем тесты для двух случаев, которые мы пропустили ранее, вызов только `operation`:

{% highlight ruby %}
it 'executes the operation provided without an initial value' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.reduce(:+)
  expect(result).to eq(10)
end
{% endhighlight %}

И вызов только блока:

{% highlight ruby %}
it 'executes the block provided without an initial value' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  result = items.reduce do |accumulator,element|
    accumulator + element
  end
  expect(result).to eq(10)
end
{% endhighlight %}

Почему эти два теста?

Посмотрим на них, в общем-то они одинаковые, в обоих случаях нет аккумулятора, разница только в том, что в одном передается блок, но оба должны вытащить первый элемент коллекции и затем запустить `reduce`.

Если мы попробуем запустить эти тесты:

{% highlight ruby %}
Failures:

1) CustomEnumerable reduce executes the operation provided without an initial value
  Failure/Error: @items.each(&block)
  NoMethodError:
  undefined method `call' for nil:NilClass
  # ./lib/custom_enumerable.rb:47:in `block in reduce'
  # ./spec/custom_enumerable_spec.rb:12:in `each'
  # ./spec/custom_enumerable_spec.rb:12:in `each'
  # ./lib/custom_enumerable.rb:46:in `reduce'
  # ./spec/custom_enumerable_spec.rb:128:in `block (3 levels) in <top (required)>'

2) CustomEnumerable reduce executes the block provided without an initial value
  Failure/Error: result = items.reduce do |accumulator,element|
  ArgumentError:
  wrong number of arguments (0 for 1..2)
  # ./lib/custom_enumerable.rb:32:in `reduce'
  # ./spec/custom_enumerable_spec.rb:134:in `block (3 levels) in <top (required)>'
{% endhighlight %}

Как мы будем делать это? Большая часть кода будет заниматься жонглированием параметров. `reduce` был объявлен задолго до того как в `ruby` появились именованные параметры, нет магического способа определить аккумулятор это операция или нет, мы должны проверить это вручную.

Также, нам нужен способ получить первый элемент коллекции, иначе нам придется это делать в самом методе `reduce`. Давайте начнем с реализации метода `first`:

{% highlight ruby %}
def first
  found = nil
  each do |element|
    found = element
    break
  end
  found
end
{% endhighlight %}

Использовать его очень просто:

{% highlight ruby %}
it 'returns the first element inside a collection' do
  items = ArrayWrapper.new(1, 2, 3, 4)
  expect(items.first).to eq(1)
end

it 'returns nil if the collection is empty' do
  items = ArrayWrapper.new
  expect(items.first).to be_nil
end
{% endhighlight %}

Если вы спрашиваете себя - почему он использует `break` а не просто возвращает элемент из `each`, попробуйте поменять код на:

{% highlight ruby %}
def first
  each do |element|
    return element
  end
end
{% endhighlight %}
<br>
Что сейчас произошло?
<br>
Вторая спека которая ожидает что вернется `nil`, когда коллекция пустая, провалилась. Почему? Потому что `each` возвращает саму коллекцию когда запускается, так как код ни разу не был выполнен (коллекция пустая!) `each` просто возвращает себя а не `nil`, как мы ожидаем. Вот почему нам нужно использовать `return` и `break`.

Теперь, когда метод `first` написан, давайте сделаем финальную реализацию `reduce`:

{% highlight ruby %}
def reduce(accumulator = nil, operation = nil, &block)
  if accumulator.nil? && operation.nil? && block.nil?
    raise ArgumentError, "you must provide an operation or a block"
  end

  if operation && block
    raise ArgumentError, "you must provide either an operation symbol or a block, not both"
  end

  if operation.nil? && block.nil?
    operation = accumulator
    accumulator = nil
  end

  block = case operation
    when Symbol
      lambda { |acc, value| acc.send(operation, value) }
    when nil
      block
    else
    raise ArgumentError, "the operation provided must be a symbol"
  end

  if accumulator.nil?
    ignore_first = true
    accumulator = first
  end

  index = 0

  each do |element|
    unless ignore_first && index == 0
      accumulator = block.call(accumulator, element)
    end
    index += 1
  end
  accumulator
end
{% endhighlight %}

Учитывая, что мы не знаем как будут переданы параметры или структуру коллекции, мы не можем оптимизировать данный вызов (если только не задублируем код немного, например, добавив упорядочивание реализации если переда аккумулятор). Но, так как мы хотим, чтобы код работал во всех случаях, мы будем надеяться что классы, включающие данный модуль будут предоставлять реализацию с более ровными структурами.

Код начинается с проверки всех параметров, если параметры не переданы, выходим, нечего делать. Далее начинается проверка какую ситуацию мы решаем, вначале проверяется - если `operation` и `block` - `nil`, значит поле `accumulator` должно быть операцией и значит у нас нет аккумулятора.

Когда у нас есть параметр `operation` мы достигаем другого куска, проверка аккумулятора. Если аккумулятор `nil`, мы должны брать первый элемент коллекции, а также сказать методу игнорировать первую итерацию.

Наша новая петля `each` теперь проверяет специальные переменные в случае пустого аккумулятора, так что мы можем безопасно обрабатывать коллекцию без дублирования значений. Это, кстати, неплохое место для оптимизации.

И это завершает реализацию метода `reduce`, посмотрите можете ли вы найти более быстрое или качественное решение, безусловно есть варианты лучше моего.

###reduce magic

Теперь, когда у нас есть реализация `reduce`, есть много методов, которые мы можем построить на его базе, например `min` и `max`:

{% highlight ruby %}
def min
  reduce do |accumulator,element|
    accumulator > element ? element : accumulator
  end
end

def max
  reduce do |accumulator,element|
    accumulator < element ? element : accumulator
  end
end
{% endhighlight %}

Наш `reduce` уже обрабатывает вариант с пустым значением:

{% highlight ruby %}
it 'produces nil if it is empty' do
  items = ArrayWrapper.new
  expect(items.max).to be_nil
end
{% endhighlight %}

И случай одиночного варианта:

{% highlight ruby %}
it 'produces 1 as the max result' do
  items = ArrayWrapper.new(1)
  expect(items.max).to eq(1)
end
{% endhighlight %}

Нашим реализациям `min` и `max` не нужно заботиться об этом, все что нужно сделать это передать блок который делает сравнение и возвращает наибольший или наименьший элемент, всю остальную работу делает `reduce`. Мощно, не так ли?

Есть еще много методов `Enumerable` помимо `reduce`, такие как `each_with_index`, `each_with_object`, `count`, `max_by, min_by` и другие, попробуйте также реализовать их на `ruby`.

Ну и все что было сделано в этом примере доступно на <a href="https://github.com/mauricio/enumerable_example" target="_blank">github</a>.










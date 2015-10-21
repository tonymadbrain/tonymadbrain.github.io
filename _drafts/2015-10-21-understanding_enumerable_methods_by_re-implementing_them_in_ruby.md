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

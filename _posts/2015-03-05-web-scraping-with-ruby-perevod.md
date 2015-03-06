---
title: Веб парсинг на Ruby - перевод
layout: post
permalink: /2015-03-05-web-scraping-with-ruby-perevod/
---

Это перевод статьи <a href="https://www.chrismytton.uk/2015/01/19/web-scraping-with-ruby/" target="_blank">Web Scraping with Ruby</a>, которую я нашел полезной при изучении языка программирования Ruby. Парсинг меня интересует в личных целях, но мне кажется это полезный навык и способ изучить язык.   

####*Начало перевода*

Парсинг веба на Ruby легче чем вы можете думать. Давайте начнем с простого примера, я хочу получить красиво отформатированный JSON массив объектов представляющий список фильмов с сайта <a href="http://www.cubecinema.com/programme" target="_blank">местного независимого кинотеатра.</a>

В начале нам нужен способ скачать html страницу, которая содержит все объявления о фильмах. В Ruby есть встроенный http клиент, ```Net::HTTP```, а также надстройку над ним - ```open-uri```[^1]. Итак, первая вещь, которую надо сделать - это скачать html с удаленного сервера. 

{% highlight ruby %}
require 'open-uri'

url = 'http://www.cubecinema.com/programme'
html = open(url)
{% endhighlight %}

Отлично, теперь у нас есть страница, которую мы хотим парсить, теперь нам нужно вытащить некоторую информацию из нее. Лучший инструмент для этого - <a href="http://www.nokogiri.org/" target="_blank">Nokogiri</a>. Мы создаем новый экземпляр Nokogiri для нашего html, который мы только что скачали. 

{% highlight ruby %}
require 'nokogiri'

doc = Nokogiri::HTML(html)
{% endhighlight %}

Nokogiri крут, потому что позволяет обращаться к html используя CSS селекторы, что, на мой взгляд, гораздо удобнее чем использовать xpath.

Ок, теперь у нас есть документ, из которого мы можем вытащить список кинофильмов. Каждый элемент списка имеет такую html структуру, как показано ниже.

{% highlight html %}
<div class="showing" id="event_7557">
  <a href="/programme/event/live-stand-up-monty-python-and-the-holy-grail,7557/">
    <img src="/media/diary/thumbnails/montypython2_1.png.500x300_q85_background-%23FFFFFF_crop-smart.jpg" alt="Picture for event Live stand up + Monty Python and the Holy Grail">
  </a>
  <span class="tags"><a href="/programme/view/comedy/" class="tag_comedy">comedy</a> <a href="/programme/view/dvd/" class="tag_dvd">dvd</a> <a href="/programme/view/film/" class="tag_film">film</a> </span>
  <h1>
    <a href="/programme/event/live-stand-up-monty-python-and-the-holy-grail,7557/">
      <span class="pre_title">Comedy Combo presents</span>
      Live stand up + Monty Python and the Holy Grail
      <span class="post_title">Rare screening from 35mm!</span>
    </a>
  </h1>
  <div class="event_details">
    <p class="start_and_pricing">
      Sat 20 December | 19:30
      <br>
    </p>
    <p class="copy">Brave (and not so brave) Knights of the Round Table! Gain shelter from the vicious chicken of Bristol as we gather to bear witness to this 100% factually accurate retelling ... [<a class="more" href="/programme/event/live-stand-up-monty-python-and-the-holy-grail,7557/">more...</a>]</p>
  </div>
</div>
{% endhighlight %} 

###Обработка html

Каждый фильм имеет css класс ```.showing```, так что мы можем выбрать все шоу и обработать их по очереди. 

{% highlight ruby %}
showings = []
doc.css('.showing').each do |showing|
  showing_id = showing['id'].split('_').last.to_i
  tags = showing.css('.tags a').map { |tag| tag.text.strip }
  title_el = showing.at_css('h1 a')
  title_el.children.each { |c| c.remove if c.name == 'span' }
  title = title_el.text.strip
  dates = showing.at_css('.start_and_pricing').inner_html.strip
  dates = dates.split('<br>').map(&:strip).map { |d| DateTime.parse(d) }
  description = showing.at_css('.copy').text.gsub('[more...]', '').strip
  showings.push(
    id: showing_id,
    title: title,
    tags: tags,
    dates: dates,
    description: description
  )
end
{% endhighlight %}

Давайте разберем по частям код представленный выше.

{% highlight ruby %}
showing_id = showing['id'].split('_').last.to_i
{% endhighlight %}

В начале мы берем уникальный идентификатор id, который любезно выставлен как атрибут html идентификатора в разметке. Используя квадратные скобки мы можем получить доступ к атрибутам элементов. Таким образом, в случае html представленного выше, ```showing['id']``` должен быть "event_7557". Нам интересен только числовой идентификатор, так что мы разделяем результат с помощью подчеркивания, ```.split('_')``` и затем берем последний элемент из получившегося массива и конвертируем в целочисленный формат, ```.last.to_i```.

{% highlight ruby %}
tags = showing.css('.tags a').map { |tag| tag.text.strip }
{% endhighlight %}

Здесь мы находим все теги для фильма, используя ```.css``` метод, который возвращает массив совпадающих элементов. Затем мы мапим (применяем метод map) элементы, берем из них текст и убираем в нем пробелы. Для нашего html результат будет ```["comedy", "dvd", "film"]```.

{% highlight ruby %}
title_el = showing.at_css('h1 a')
title_el.children.each { |c| c.remove if c.name == 'span' }
title = title_el.text.strip
{% endhighlight %}

Код для получения заголовка немного сложнее, потому что этот элемент в html содержит некоторые добавочные span элементы с префиксами и суффиксами. Мы берем заголовок, используя ```.at_css```, который возвращает один соответствующий элемент. Затем мы перебираем каждого потомка заголовка и удаляем лишние span. В конце, когда span убраны мы получаем текст заголовка и чистим его от лишних пробелов. 

{% highlight ruby %}
dates = showing.at_css('.start_and_pricing').inner_html.strip
dates = dates.split('<br>').map(&:strip).map { |d| DateTime.parse(d) }
{% endhighlight %}

Далее код для получения даты и времени показа. Здесь немного сложнее, потому что фильмы могут показывать несколько дней и, иногда, цена может быть в этом же элементе. Мы мапим даты, которые найдем с помощью  ```DateTime.parse``` и в результате получаем массив Ruby объектов - ```DateTime```. 

{% highlight ruby %}
description = showing.at_css('.copy').text.gsub('[more...]', '').strip
{% endhighlight %}

Получение описания довольно простой процесс, единственное что стоит сделать, это убрать текст ```[more...]``` используя ```.gsub```

{% highlight ruby %}
showings.push(
    id: showing_id,
    title: title,
    tags: tags,
    dates: dates,
    description: description
  )
{% endhighlight %}

Теперь, имея все необходимые части в переменных, мы можем записать их в наш хеш (hash), созданный для оторажения всех фильмов. 

###Вывод в JSON

Теперь, когда у нас отбирается каждый фильм и мы их массив, можем конвертировать результат в формат JSON. 

{% highlight ruby %}
require 'json'

puts JSON.pretty_generate(showings)
{% endhighlight %}

Данный код выводит массив showings перекодированный в формат JSON, при запуске скрипта вывод можно перенаправить в файл или другую программу для дальнейшей обработки. 

###Собираем все вместе

Собрав все части в одном месте мы получаем полную версию нашего скрипта. 

{% highlight ruby %}
require 'open-uri'
require 'nokogiri'
require 'json'

url = 'http://www.cubecinema.com/programme'
html = open(url)

doc = Nokogiri::HTML(html)
showings = []
doc.css('.showing').each do |showing|
  showing_id = showing['id'].split('_').last.to_i
  tags = showing.css('.tags a').map { |tag| tag.text.strip }
  title_el = showing.at_css('h1 a')
  title_el.children.each { |c| c.remove if c.name == 'span' }
  title = title_el.text.strip
  dates = showing.at_css('.start_and_pricing').inner_html.strip
  dates = dates.split('<br>').map(&:strip).map { |d| DateTime.parse(d) }
  description = showing.at_css('.copy').text.gsub('[more...]', '').strip
  showings.push(
    id: showing_id,
    title: title,
    tags: tags,
    dates: dates,
    description: description
  )
end

puts JSON.pretty_generate(showings)
{% endhighlight %}

Если сохранить это в файл, например, ```scraper.rb``` и запустить ```ruby scraper.rb``` то вы должны увидеть вывод в формате JSON. Он должен быть похож на то, что представлено ниже.

{% highlight json %}
[
  {
    "id": 7686,
    "title": "Harry Dean Stanton - Partly Fiction",
    "tags": [
      "dcp",
      "film",
      "ttt"
    ],
    "dates": [
      "2015-01-19T20:00:00+00:00",
      "2015-01-20T20:00:00+00:00"
    ],
    "description": "A mesmerizing, impressionistic portrait of the iconic actor in his intimate moments, with film clips from some of his 250 films and his own heart-breaking renditions of American folk songs. ..."
  },
  {
    "id": 7519,
    "title": "Bang the Bore Audiovisual Spectacle: VA AA LR + Stephen Cornford + Seth Cooke",
    "tags": [
      "music"
    ],
    "dates": [
      "2015-01-21T20:00:00+00:00"
    ],
    "description": "An evening of hacked TVs, 4 screen cinematic drone and electroacoustics. VAAALR: Vasco Alves, Adam Asnan and Louie Rice create spectacles using distress flares, C02 and junk electronics. Stephen Cornford: ..."
  }
]
{% endhighlight %}

И это все! Это всего лишь базовый пример парсинга. Сложнее парсить сайт, который требует в начале авторизоваться, для таких случаев, я рекомендую посмотреть в сторону <a href="http://docs.seattlerb.org/mechanize/GUIDE_rdoc.html" target="_blank">mechanize</a>, который работает над Nokogiri.

Надеюсь данное введение в парсинг даст вам идеи о данных, которые вы хотите видеть в более структурированном формате, используя методы, описанные выше.  

####*Конец перевода*

[^1]: Open-uri хорош для базовых вещей, вроде тех, что мы делаем в уроке, но у него есть некоторые <a href="https://bugs.ruby-lang.org/issues/3719" target="_blank">проблемы</a>, поэтому, возможно, вы захотите найти другой http клиент для продакшн среды. 



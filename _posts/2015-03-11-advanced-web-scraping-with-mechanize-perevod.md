---
title: Продвинутый парсинг веб-сайтов с Mechanize - перевод
layout: post
permalink: /web-scraping-with-ruby-perevod/
---

*В продолжение темы <a href="http://doam.ru/web-scraping-with-ruby-perevod/" target="_blank">парсинга сайтов на Ruby</a>, я решил перевести следующую статью этого же автора.*
  
В предыдыдущей записи я описал основы - <a href="https://www.chrismytton.uk/2015/01/19/web-scraping-with-ruby/" target="_blank">введение в веб парсинг на Ruby</a>. В конце поста, я упомянул инструмент Mechanize, который используется для продвинутого парсинга. 

Данная статья объясняет как делать продвинутый парсинг веб-сайтов с использованием Mechanize, который, в свою очередь, позволяет делать отличную обработку HTML, работая над Nokogiri. 

## Парсинг отзывов с Pitchfork

Mechanize из коробки предоставляет инструменты, которые позволяют заполнять поля в формах, переходить по ссылкам и учитывать файл robots.txt. В данной записи, я покажу как это использовать для получения последних отзывов с сайта <a href="http://pitchfork.com/" target="_blank">Pitchfork</a> [^1].

Отзывы разделены на несколько страниц, поэтому, мы не можем просто взять одну страницу и разобрать её с помощью Nokogiri. Здесь то нам и понадобится Mechanize с его способностью кликать на ссылки и переходить по ним на другие страницы. 

### Установка

Вначале нужно установить сам <a href="http://docs.seattlerb.org/mechanize/GUIDE_rdoc.html" target="_blank">Mechanize</a> и его зависимости через Rubygems.

{% highlight bash %}
$ gem install mechanize
{% endhighlight %}

Можно приступить к написанию нашего парсера. Создадим файл ```scraper.rb``` и добавим в него некоторые ```require```. Это укажет на зависимости, которые необходимы для нашего скрипта. ```date``` и ```json``` это части стандартной библиотеки ruby, так что дополнительно устанавливать их нет необходимости. 

{% highlight ruby %}
require 'mechanize'
require 'date'
require 'json'
{% endhighlight %}

Теперь мы можем начать использовать Mechanize. Первое, что нужно сделать, это создать новый экземпляр класса Mechanize (```agent```) и использовать его, что скачать страницу (```page```).

{% highlight ruby %}
agent = Mehanize.new
page  = agent.get("http://pitchfork.com/reviews/albums/")
{% endhighlight %} 

### Находим ссылки на отзывы

Теперь мы можем использовать объект ```page```, чтобы найти ссылки на отзывы. 
Mehanize позволяет использовать метод ```.links_with```, который, как следует из названия, находит ссылки с указанными атрибутами. Здесь мы ищем ссылки, которые соответствуют регулярному выражению.

Это вернет массив ссылок, но нам нужны только ссылки на отзывы, не пагинация. Чтобы удалить ненужное мы можем вызвать ```.reject``` и отбросить ссылки, похожие на пагинацию.

{% highlight ruby %}
review_links = page.links_with(href: %r{^/reviews/albums/\w+})

review_links = review_links.reject do |link|
  parent_classes = link.node.parent['class'].split
  parent_classes.any? { |p| %w[next-container page-number].include?(p) }
end
{% endhighlight %}

В показательных целях и чтобы не нагружать сервера Pitchfork, мы будем брать ссылки только на первые 4 отзыва.

{% highlight ruby %}
review_links = review_links[0...4]
{% endhighlight %}

### Обработка каждого отзыва

Мы получили список ссылок и хотим обработать каждую в отдельности, для этого мы будем использовать метод ```.map``` и возвращать хеш после каждой итерации.

Объект ```page``` имеет метод ```.search``` который делегируется методу ```.search``` Nokogiri. Это означает, что мы можем использовать CSS селектор как аргумент для ```.serach``` и он вернет массив совпавших элементов.

Сначала мы возьмем метаданные обзора, используя CSS селектор ```#main .review-meta .info``` а затем будем искать внутри ```review_meta``` элемента кусочки информации, которая нам нужна. 

{% highlight ruby %}
reviews = review_links.map do |link|
  review = link.click
  review_meta = review.search('#main .review-meta .info')
  artist = review_meta.search('h1')[0].text
  album = review_meta.search('h2')[0].text
  label, year = review_meta.search('h3')[0].text.split(';').map(&:strip)
  reviewer = review_meta.search('h4 address')[0].text
  review_date = Date.parse(review_meta.search('.pub-date')[0].text)
  score = review_meta.search('.score').text.to_f
  {
    artist: artist,
    album: album,
    label: label,
    year: year,
    reviewer: reviewer,
    review_date: review_date,
    score: score
  }
end
{% endhighlight %}

Теперь мы имеем массив хешей с обзорами, который мы можем, например, вывести в JSON формате. 

{% highlight json %}
review_links = review_links[0...4]
{% endhighlight %}

puts JSON.pretty_generate(reviews)

### Все вместе

Скрипт полностью:

{% highlight ruby %}
require 'mechanize'
require 'date'
require 'json'

agent = Mechanize.new
page = agent.get("http://pitchfork.com/reviews/albums/")

review_links = page.links_with(href: %r{^/reviews/albums/\w+})

review_links = review_links.reject do |link|
  parent_classes = link.node.parent['class'].split
  parent_classes.any? { |p| %w[next-container page-number].include?(p) }
end

review_links = review_links[0...4]

reviews = review_links.map do |link|
  review = link.click
  review_meta = review.search('#main .review-meta .info')
  artist = review_meta.search('h1')[0].text
  album = review_meta.search('h2')[0].text
  label, year = review_meta.search('h3')[0].text.split(';').map(&:strip)
  reviewer = review_meta.search('h4 address')[0].text
  review_date = Date.parse(review_meta.search('.pub-date')[0].text)
  score = review_meta.search('.score').text.to_f
  {
    artist: artist,
    album: album,
    label: label,
    year: year,
    reviewer: reviewer,
    review_date: review_date,
    score: score
  }
end

puts JSON.pretty_generate(reviews)
{% endhighlight %}

Сохранив этот код в нашем файле ```scraper.rb``` и запустив его командой:

{% highlight bash %}
$ ruby scraper.rb
{% endhighlight %}

Мы получим, что-то похожее на это:

{% highlight json %}
[
  {
    "artist": "Viet Cong",
    "album": "Viet Cong",
    "label": "Jagjaguwar",
    "year": "2015",
    "reviewer": "Ian Cohen",
    "review_date": "2015-01-22",
    "score": 8.5
  },
  {
    "artist": "Lupe Fiasco",
    "album": "Tetsuo & Youth",
    "label": "Atlantic / 1st and 15th",
    "year": "2015",
    "reviewer": "Jayson Greene",
    "review_date": "2015-01-22",
    "score": 7.2
  },
  {
    "artist": "The Go-Betweens",
    "album": "G Stands for Go-Betweens: Volume 1, 1978-1984",
    "label": "Domino",
    "year": "2015",
    "reviewer": "Douglas Wolk",
    "review_date": "2015-01-22",
    "score": 8.2
  },
  {
    "artist": "The Sidekicks",
    "album": "Runners in the Nerved World",
    "label": "Epitaph",
    "year": "2015",
    "reviewer": "Ian Cohen",
    "review_date": "2015-01-22",
    "score": 7.4
  }
]
{% endhighlight %}

Если хотите вы можете перенаправить эти данные в файл.

{% highlight bash %}
$ ruby scraper.rb > reviews.json
{% endhighlight %}

### Заключение

Это только вершина возможностей Mechanize. В этой статье я даже не коснулся способности Mechanize заполнять и отправлять формы. Если вам это интересно, то я рекомендую почитать <a href="http://docs.seattlerb.org/mechanize/GUIDE_rdoc.html" target="_blank">руководство Mechanize</a> и <a href="http://docs.seattlerb.org/mechanize/EXAMPLES_rdoc.html" target="_blank">примеры использования.</a>

Много людей в комментариях к предыдущему посту сказали, что я должен был просто использовать Mechanize. Хотя я согласен, что Mechanize является отличным инструментом, тот пример, который я привел в первой записи на эту тему был простым, и использование в нем Mechanize, как мне кажется, является излишним.

Однако, учитывая способности Mechanize, я начинаю думать, что даже для простых задач парсинга, зачастую, будет лучше использовать именно его. 

[^1]: Вы всегда должны парсить аккуратно. Прочитайте статью <a href="https://blog.scraperwiki.com/2012/04/is-scraping-legal/" target="_blank">Is scraping legal?</a> из блога ScraperWiki для ознакомления с обсуждениями на эту тему. 
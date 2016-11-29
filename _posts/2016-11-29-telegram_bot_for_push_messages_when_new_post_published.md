---
layout: post
title: Пишем Telegram бота на Ruby для уведомлений в канале
permalink: /telegram_bot_for_push_messages_when_new_post_published/
excerpt: "Задача бота парсить rss ленту и при появлении новых постов слать уведомление в Telegram канал"
tags:
  - Ruby
  - Telegram
  - Heroku
  - Gitlab
date: 2016-11-29T21:59:32+03:00
---

### Вступление

Заикнулся в присутствии нового коллеги о своем блоге, первый его вопрос был "что за блог?", а второй "а телеграм бот у тебя есть?". Поймал себя на мысли *неужели я стал ретроградом*. Когда начался хайп вокруг влогов и youtube каналов я остался верен теплому ламповому формату текстовых статей, так и сейчас, считаю что нет необходимости иметь свой Telegram канал, но задача меня заинтересовала.
<br />
<br />
Вокруг Telegram ботов сейчас много шумихи, хотя в принципе, последний год я итак уже занимался чат ботами, для реализации ChatOps. Не собираюсь писать тут тривиальные вещи как завести своего бота или канал, это сделали за меня, например <a href="https://habrahabr.ru/post/316222/" target="_blank">тут</a>. Не хотелось делать что-то надуманное, только ради "попробовать" и я решил что более менее полезной задачей будет уведомление о новых статьях в этом же блоге и только потом понял, что в принципе, мою реализацию можно использовать для любой `RSS` ленты c небольшими правками *под себя*.

{% include _toc.html %}

### Наивная реализация или *тупой бот*

> Первое что нужно сделать это создать бота и получить API токен.

Недолго думая, я взял самую популярную либу-обертку для ботов Telegram - <a href="https://github.com/atipugin/telegram-bot-ruby" target="_blank">gem telegram-bot-ruby</a> и наваял следующий код:

{% highlight ruby %}
require 'rss'
require 'telegram/bot'

token = ENV['TELEGRAM_BOT_API_KEY']

rss = RSS::Parser.parse('http://doam.ru/feed.xml', false)

Telegram::Bot::Client.run(token) do |bot|
  rss.items.each do |item|
    bot.api.sendMessage(chat_id: "@doam_ru", text: item.link.href)
  end
end
{% endhighlight %}

Что же тут происходит? Все очень просто, вот здесь:

{% highlight ruby %}
require 'rss'
require 'telegram/bot'
{% endhighlight %}

подключаем библиотеки для работы с RSS и Telegram, а вот здесь:

{% highlight ruby %}
token = ENV['TELEGRAM_BOT_API_KEY']
{% endhighlight %}

сетим в переменную с именем `token` наш API токен, который получили от `@BotFather`.

> Здесь я использую переменные окружения (Environment variables), чтобы это работало, перед запуском скрипта нужно выполнить в командной строке `export TELEGRAM_BOT_API_KEY=123456789`, где вместо 123456789 нужно вставить собственно токен. Использование переменных окружения один из двенадцати факторов приложения согласно - <a href="https://12factor.net/" target="_blank">Adam Wiggins</a>

Затем, с помощью строчки:

{% highlight ruby %}
rss = RSS::Parser.parse('http://doam.ru/feed.xml', false)
{% endhighlight %}

сохраняем в объект `rss` всю `RSS` ленту моего блога (я точно знаю что у меня там только 10 записей, поэтому не боюсь никаких переполнений или задержек).

{% highlight ruby %}
Telegram::Bot::Client.run(token) do |bot|
  rss.items.each do |item|
    bot.api.sendMessage(chat_id: "@doam_ru", text: item.link.href)
  end
end
{% endhighlight %}

После этого мы создаем бот клиента, обходим каждый `item` внутри `rss` и отправляем его ссылку в канал Telegram.
<br />
<br />
Таким образом, при каждом запуске скрипта в канал будет отправляться 10 сообщений с одинаковыми ссылками. Я использую бота, хотя для такого же функционала, например, в Slack я бы использовал Incoming Hooks.

> Кстати, чтобы бот мог слать сообщения в канал, его нужно добавить в администраторы этого канала.

На этом этапе я понял что нужно хранить состояние постов, т.е. запоминать информацию какие записи уже отправлены в канал, а какие еще нет.

### Используем простую БД или *чуть более умный бот*

На самом деле новая версия бота растянулась на 55 строк кода, и вот он целиком:

{% highlight ruby %}
require 'telegram/bot'
require 'rss'
require 'sdbm'
require 'json'
require 'logger'

logger = Logger.new(STDOUT)

if ENV['TELEGRAM_BOT_API_KEY'].nil?
  logger.fatal "Environment variable TELEGRAM_BOT_API_KEY not set!"
  exit 0
else
  token = ENV['TELEGRAM_BOT_API_KEY']
end

rss = RSS::Parser.parse('http://doam.ru/feed.xml', false)

SDBM.open 'doam_posts.db' do |posts|
  rss.items.each do |item|
    key       = item.link.href
    title     = item.title.content
    published = item.published.content
    # next if posts[key]
    if posts.has_key?(key)
      logger.info "Post exist in DB will not rewrite"
    else
      posts[key] = JSON.dump(
        title: title,
        published: published,
        sended: 0
      )
    end
  end

  hash = {}
  posts.each do |k,v|
    hash[k] = JSON.parse(v)
    if hash[k]["sended"] == 0
      text = "Новая запись в блоге: #{hash[k]["title"]} - #{k}"
      Telegram::Bot::Client.run(token) do |bot|
        if bot.api.sendMessage(chat_id: "@doam_ru", text: text)
          posts[k] = JSON.dump(
            title: hash[k]["title"],
            published: hash[k]["published"],
            sended: 1
          )
          logger.info "Successfuly send #{hash[k]} to telegram!"
        else
          logger.error "Can not send #{hash[k]} to telegram!"
        end
      end
    end
  end
end
{% endhighlight %}

Опять же приведу разбор этого кода по кусочкам далее по тексту.

{% highlight ruby %}
require 'telegram/bot'
require 'rss'
require 'sdbm'
require 'json'
require 'logger'
{% endhighlight %}

Я использую теже две библиотеки что и раньше `rss` и `telegram`, затем подключаю `sdbm` это встроенная либа Ruby, которая предоставляет простое хранилище типа ключ-значение (key-value), в качестве ключей или значений могут выступать только строки. Далее я подключаю `json`, чтобы легко кодировать объекты в строки и декодировать обратно. И еще одной библиотекой является `logger`, который предоставляет простой способ для отладки.

{% highlight ruby %}
logger = Logger.new(STDOUT)

if ENV['TELEGRAM_BOT_API_KEY'].nil?
  logger.fatal "Environment variable TELEGRAM_BOT_API_KEY not set!"
  exit 1
else
  token = ENV['TELEGRAM_BOT_API_KEY']
end

rss = RSS::Parser.parse('http://doam.ru/feed.xml', false)
{% endhighlight %}

Сперва делаем простые вещи, создаем объект для логирования и сетим переменную окружения.

> Устанавливаем переменную окружения в этот раз мы чуть сложнее. Вначале мы проверяем что ENV пустая и если это так то выбрасываем ошибку через логгер и выходим из программы c использованием `exit` кода 1, в обратном случае, если переменная не пустая, записываем её значение в переменную, которую мы будем использовать в дальнейшем.

Парсинг `RSS` ленты происходит таким же образом как и ранее.

{% highlight ruby %}
SDBM.open 'doam_posts.db' do |posts|
{% endhighlight %}

Далее, этой строчкой мы открываем нашу базу данных, которая является просто файлами в нашей файловой системе, в случае если базы не существует она будет создана с нуля.

{% highlight ruby %}
  rss.items.each do |item|
    key       = item.link.href
    title     = item.title.content
    published = item.published.content
    # next if posts[key]
    if posts.has_key?(key)
      logger.info "Post exist in DB will not rewrite"
    else
      posts[key] = JSON.dump(
        title: title,
        published: published,
        sended: 0
      )
    end
  end
{% endhighlight %}

И после этого мы начинаем первый цикл: обходим все полученные rss итемы, записываем ссылки, заголовок и дату публикации соответственно в переменные key, title и published. Проверяем есть ли в нашей базе ключ с таким же значением как наш и если есть просто выводим в лог текст, что не будем ничего перезаписывать (это нужно только на этапе отладки, но вообще не обязательно), в обратном случае, если в базе нет записи с таким ключом мы генерируем json строку и записываем её в базу. В качестве ключа я выбрал URL, так как они обеспечивают уникальность, всегда написаны в одном регистре и латиницей.

{% highlight ruby %}
  hash = {}
  posts.each do |k,v|
  hash[k] = JSON.parse(v)
  if hash[k]["sended"] == 0
    text = "Новая запись в блоге: #{hash[k]["title"]} - #{k}"
    Telegram::Bot::Client.run(token) do |bot|
      if bot.api.sendMessage(chat_id: "@doam_ru", text: text)
        posts[k] = JSON.dump(
          title: hash[k]["title"],
          published: hash[k]["published"],
          sended: 1
        )
        logger.info "Successfuly send #{hash[k]} to telegram!"
      else
        logger.error "Can not send #{hash[k]} to telegram!"
      end
    end
  end
end
{% endhighlight %}

Следующим шагом я создаю объект типа `Hash` и прохожусь по всем записям которые есть в базе. С помощью `hash[k] = JSON.parse(v)` я делаю парсинг строки значения и создаю вложенные хеши. Затем проверяю значение поля `sended`, если там 0 то генерирую текст и отправляю его в канал, после чего перезаписываю объект cо значением 1, чтобы не отправить эту же запись при следующем запуске.

> На самом деле это не совсем рабочая версия кода, я почему-то не закоммитил тот момент когда довел работу с SDBM до ума. Можете попробовать сами понять что здесь не так.

Теперь уже я решил попробовать задеплоить мой код на Heroku и выполнить его там. С использоавнием раннера задач все получилось, да только вот Heroku не сохраняет файлы между запусками задачи (да и вообще). Так что мое решение с SDBM является быстрым и простым, но может быть использовано только как selfhosted.

### Прикручиваем РСУБД или *умеренно сообразительный бот*

Пост становится довольно длинным, но вы же вместе сомной прошли все этапы разработки этого бота и уже в курсе дела, поэтому привожу код обновленной версии:

{% highlight ruby %}
require 'telegram/bot'
require 'rss'
require 'sdbm'
require 'json'
require 'logger'
require 'pg'

class DoamTelegramBot

  def initialize(url, channel)
    @logger   = Logger.new(STDOUT)

    if ENV['TELEGRAM_BOT_API_KEY'].nil?
      @logger.fatal "Environment variable TELEGRAM_BOT_API_KEY not set!"
      exit 0
    else
      @token = ENV['TELEGRAM_BOT_API_KEY']
    end

    @url      = url
    @channel  = channel
    uri       = URI.parse(ENV['DATABASE_URL'])
    @db       = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    @rss      = RSS::Parser.parse(url, false)

    @db.exec("CREATE TABLE IF NOT EXISTS posts (id serial, url varchar(450) NOT NULL, sended bool DEFAULT false)")
  end

  def sync
    @rss.items.each do |item|
      url = item.link.href
      if @db.exec("SELECT exists (SELECT 1 FROM posts WHERE url = '#{url}' LIMIT 1)::int").values[0][0].to_i == 1
        @logger.info "Post exist in DB will not rewrite"
      else
        if @db.exec("INSERT INTO posts (url) VALUES ('#{url}')")
          @logger.info "Write post to DB #{url}"
        end
      end
    end
  end

  def send
    urls = @db.exec("SELECT url FROM posts WHERE sended = false")
    urls.each do |url|
      text = "Новая запись в блоге - #{url['url']}"
      if telegram_send(text)
        @db.exec("UPDATE posts SET sended = true WHERE url = '#{url['url']}'")
      end
    end
  end

  private

  def telegram_send(message)
    Telegram::Bot::Client.run(@token) do |bot|
      if bot.api.sendMessage(chat_id: "#{@channel}", text: message)
        @logger.info "Successfuly send #{message} to telegram!"
        true
      else
        @logger.error "Can not send #{message} to telegram!"
        false
      end
    end
  end
end
{% endhighlight %}

Здесь проделывается точно такая же работа: иницилизируются необходимые компоннеты, синхронизируется `rss` лента и локальная база данных и отправляются ссылки на записи которые числятся в базе как "неотправленные". Только в качестве базы используется `PostgreSQL` и все это обернуто в класс и методы. Метод `initialize` выполняется при вызове метода `new` на объекте класса `DoamTelegramBot`, остальные методы нужно вызывать отдельно. И чтобы выполнить всю правильно, я создал каталог `bin` в который положил файл с именем `doam_bot` и содержимым:

{% highlight ruby %}
#!/usr/bin/env ruby
require_relative '../app'

telegram = DoamTelegramBot.new("http://doam.ru/feed.xml", "@doam_ru")
telegram.sync
telegram.send
{% endhighlight %}

В котором я указываю что для выполнения скрипта нужно использовать язык Ruby, подключаю созданный мной класс через файл `app.rb`, создаю объект `telegram` и передаю в него урл для парсинга и id канала, вызываю методы `sync` и `send`. После чего я заливаю код на Heroku и создаю периодическую задачу, например раз в сутки. И если за сутки появились новые записи то в мой канал придет уведомление, уже без моего содействия в автоматическом режиме.
<br />
<br />

### Заключение

Полностью это маленькое приложение можно посмотреть у меня в <a href="https://gitlab.com/tonymadbrain/telegram_bot" target="_blank">gitlab</a> (для этого нужно залогиниться в gitlab.com). Лицензия пока не указана, но она MIT, т.е. можете править и использовать в своих целях. Если будет время я хотел бы прикрутить еще несколько функций, например отправку не только в телеграм но и другие сервисы, а также решить проблему первого запуска, когда база наполняется новыми записями с флагом "не отправлено" но неизвестно точно какие записи уже были отправлены в канал. В любом случае готов рассмотреть ваши Merge Requests.










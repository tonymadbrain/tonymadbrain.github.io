---
layout: post
title: Hubot скрипт для developerslife.ru
excerpt: Учим бота получать свежие gif
permalink: /hubot-script-for-developerslife-ru/
tags:
  - Hubot
  - Imhonet
date: 2016-02-04T21:42:55+03:00
---

В качестве вступления: сейчас я работаю в проекте <a href="http://imhonet.ru/" target="_blank">imhonet</a> - это технически сложная система, у которой под капотом математический рекомендательный движок, а прикрыто все веб-мордой на PHP. К слову, сейчас команда активно переписывает фронтенд на стек Node.js/React/Webpack, а PHP будет только плеваться JSON-ом на запросы первого.

<br>
<img src="https://farm2.staticflickr.com/1624/24190718014_35b17690c8_o.jpg">
<br>
<br>

Но данный пост не об этом. Я работаю системным администратором и являюсь евангелистом <a href="https://speakerdeck.com/jnewland/chatops-at-github" target="_blank">chatOps</a>. Если коротко, суть в том, чтобы различные админские (и не только) задачи запускать простыми текстовыми командами из чата и туда же получать результаты. Не всем подходит эта мета, не буду сейчас расписывать плюсы и минусы. Я уделяю chatOps время, которое остается от выполнения основных задач, поэтому развиваю нашего бота не так быстро как хотелось бы, но так или иначе, он у нас есть.

Также, в данной записи я не буду подробно расписывать что умеет наш бот, потому что это либо интеграции с внутренними сервисами, либо что-то костыльное, либо то, про что я не могу здесь писать. Но я с легкостью могу написать про простой скрипт для работы с API сайта <a href="http://developerslife.ru/" target="_blank">developerslife.ru</a>. И разработчики и админы любят смотреть на смешные гифки, особенно в тематике своей работы. Поэтому я реализовал следующие функции:

1. dev me - присылает одну рандомную гифку
2. dev me last - присылает последние 5 гифок
3. live update - раз в 10 минут скрипт проверяет наличие новых записей и если такие есть, присылает в заданную комнату

{% highlight coffeescript %}
module.exports = (robot)->

  # метод для проверки новых постов
  getDevGifsDigest = ->
    # получаем id комнаты, в которую будем слать новые гифки
    room = process.env.HUBOT_ROOM_FOR_DEV_GIFS

    robot.logger.info "Start method sendDevGifDigest"
    # дергаем из персистент (по дефолту redis) id последнего поста
    last_gif_id = robot.brain.get "developerslife_last"
    # если таковой нет, например первый раз запускается метод
    if last_gif_id == null
      url = "http://developerslife.ru/latest/0?json=true"
      # дергаем последние 5 постов
      robot.http( url ).get() (err, res, body)->
        # парсим JSON
        life = JSON.parse body
        # сохраняем id последнего поста, здесь можно впихнуть его отправку в комнату также
        robot.brain.set "developerslife_last", life.result[0].id
        robot.logger.info "Last gif is #{life.result[0].id}"
    else
      # иначе, если id поста есть, дергаем последние 50 (на этом сайте за 10 минут больше 50ти не появляется...пока)
      url = "http://developerslife.ru/latest/0?json=true&pageSize=50"
      robot.http( url ).get() (err, res, body)->
        life = JSON.parse body
        # обходим ответ и если id больше (на сайте id инкрементальный) чем тот, который записан у нас, то шлем эту гифку в заданную комнату
        for k,v of life.result
          if v.id > last_gif_id
            robot.messageRoom room, "#{v.description}: #{v.gifURL}" unless err
        # сбрасываем последний id и сетем новый последний id
        robot.brain.set "developerslife_last", ""
        robot.brain.set "developerslife_last", life.result[0].id
        robot.logger.info "Last gif is #{life.result[0].id}"

  # запускаем наш метод для получения новых постов раз в 10 минут (время в ms)
  setInterval((-> getDevGifsDigest()), 600000)

  # простой метод для получения рандомной гифки по запросу
  robot.respond /dev\s+me$/i, (msg)->
    url = "http://developerslife.ru/random?json=true"
    msg.http( url ).get() (err, res, body)->
      life = JSON.parse body
      msg.send "#{life.description}: #{life.gifURL}" unless err

  # простой метод для получения последних 5 постов по запросу
  robot.respond /dev\s+me\s+last$/i, (msg)->
    url = "http://developerslife.ru/latest/0?json=true"
    msg.http( url ).get() (err, res, body)->
      life = JSON.parse body
      for k,v of life.result
        msg.send "#{v.description}: #{v.gifURL}" unless err
{% endhighlight %}

Код простой, но я его прокомментировал, в любом случае вы можете задавать вопросы мне в твиттере <a href="https://twitter.com/tonymadbrain" target="_blank">@tonymadbrain</a>.

<br>
<img src="https://farm2.staticflickr.com/1561/24523370100_50e5128c91_o.jpg">
<br>


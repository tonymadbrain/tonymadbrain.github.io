---
layout: post
title: Установка Ghost blogging platform в CentOS
date: '2014-06-09 18:46:09'
excerpt: ""
permalink: /how_to_install_ghost_blog_in_centos/
redirect_from:
  - /ustanovka-ghost-blogging-platform-v-centos/
  - /how-to-install-ghost-blog-in-centos/
tags:
  - Ghost
  - Linux
  - Centos
  - Cms
---

{% include _toc.html %}

<br>
<img src="https://farm1.staticflickr.com/761/21466116380_27b5eb901e_o.jpg">
<br>
<br>

## Что такое Ghost?
О данном проекте писали на хабре, как минимум <a href="http://habrahabr.ru/post/197546/" target="_blank">здесь</a>. Так что, много рассказывать не собираюсь. Выделю самое главное:

* Это платформа для блоггинга, как, например, <a href="http://wordpress.org" target="_blank">Wordpress</a>
* Это очень быстрый движок, потому, что работает на <a href="http://nodejs.org/" target="_blank">node.js</a>
* Простой и удобный интерфейс
* Собственный магазин с платными и бесплатными шаблонами

## Установка Ghost в CentOS

Системные требования:

{% highlight bash %}
$ yum groupinstall -y "Development Tools"
$ yum install -y wget
{% endhighlight %}

### Устанавливаем Node.js

{% highlight bash %}
$ wget http://nodejs.org/dist/node-latest.tar.gz
$ tar -xzf node-latest.tar.gz
$ cd node-v*
$ ./configure 
$ make 
$ make install
$ ln -s /usr/local/bin/node /usr/bin/node
$ ln -s /usr/local/bin/npm /usr/bin/npm
{% endhighlight %}

### Устанавливаем Ghost

{% highlight bash %}
$ mkdir -p /var/www/ghost
$ cd /var/www/ghost
$ wget https://ghost.org/zip/ghost-latest.zip 
$ unzip ghost-latest.zip  
$ npm install --production
{% endhighlight %}

### Создание пользователя Ghost

{% highlight bash %}
$ useradd ghost
$ chown ghost:ghost /var/www/ghost/ -R
{% endhighlight %}

### Запуск Ghost в режиме разработчика

{% highlight bash %}
$ npm start
{% endhighlight %}

Таким образом мы запустили движок в режиме разработчика/отладки (dev) на localhost’е на порту 2368 (127.0.0.1:2368). Можно посмотреть результат, открыв в браузере адрес <a href="http://127.0.0.1:2368">http://127.0.0.1:2368</a>.

## Дальнейшая настройка Ghost

Естественно нам необходимо две вещи, чтобы блог открывался по доменному имени и на 80 порту. В папке с ghost есть два файла `config.example.js` и `config.js` (если второго нет, необходимо переименовать первый или скопировать). Считывается `config.js`.

> Заметка: в конфигурационном файле есть несколько блоков настроек, dev, production и testing. В зависимости от того в каком режиме вы будете запускать сервер такие настройки и будут применены.

Итак, чтобы решить задачу с доменным именем и портом, можно изменить настройки в конфиге самого ghost’а, а можно установить nginx и через него проксировать запросы в node.js. Тут, на мой взгляд, кому как удобнее. В конфиге ghost, нас интересует следующее:

{% highlight javascript %}
var path = require('path'),
config;

config = {
// ### Development **(default)**-  настройки для запуска в режиме DEV
development: {
// The url to use when providing links to the site, E.g. in RSS and email.
url: 'http://ghost.mysite.com', //Адрес который будет слушать встроенный веб-сервер
database: {
client: 'sqlite3',
connection: {
filename: path.join(__dirname, '/content/data/ghost-dev.db')
},
debug: false
},

server: {
// Host to be passed to node's `net.Server#listen()`
host: '0.0.0.0', //По умолчанию здесь указан localhost, если поставить 0.0.0.0
//будут слушаться все интерфейсы, либо можно выставить определенный.
// Port to be passed to node's `net.Server#listen()`, for iisnode set this to `process.env.PORT`
port: '2368' // Здесь задается порт, нас интересует 80.
},
paths: {
contentPath: path.join(__dirname, '/content/')
}
},

// ### Production – настройки для запуска в режиме Production
//Для продакшн, настройки точно такие же, однако не забывайте их поменять
production: {
url: 'http://ghost.mysite.com',
mail: {},
database: {
client: 'sqlite3',
connection: {
filename: path.join(__dirname, '/content/data/ghost.db')
},
debug: false
},
server: {
// Host to be passed to node's `net.Server#listen()`
host: '0.0.0.0',
// Port to be passed to node's `net.Server#listen()`, for iisnode set this to `process.env.PORT`
port: '80'
}
},
{% endhighlight %}

## Настройка Ghost с использованием Nginx

При этом мы сохраняем дефолтные настройки Ghost и запускаем сервер на localhost на порту 2368.

### Установка Nginx

Добавляем репозиторий Nginx

{% highlight bash %}
$ vim /etc/yum.repos.d/nginx.repo
{% endhighlight %}

В файл добавляем текст:

{% highlight bash %}
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
{% endhighlight %}

Сохраняем файл, устанавливаем Nginx, запускаем его и добавляем в автозагрузку, следующими командами:

{% highlight bash %}
$ yum install nginx -y
$ service nginx start
$ chkconfig nginx on
{% endhighlight %}

Далее создаем конфиг виртуального хоста для нашего Ghost сервера:

{% highlight bash %}
$ vim /etc/nginx/conf.d/ghost.mysite.com.conf
{% endhighlight %}

Со следующим содержимым:

{% highlight bash %}
server {
  listen 80;
  server_name yourdomain.com www.yourdomain.com;

  location / {
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   Host      $http_host;
    proxy_pass         http://127.0.0.1:2368;
  }
}
{% endhighlight %}

Для применения настроек выполняем команду:

{% highlight bash %}
$ service nginx reload
{% endhighlight %}

Вот и все, теперь ваш блог на движке Ghost доступен по адресу `yourdomain.com` на `80` порту.
<br>
<br>
Материалы по теме:

* <a href="https://ghost.org/" target="_blank">Официальный сайт Ghost </a>
* <a href="http://marketplace.ghost.org/" target="_blank">Магазин шаблонов</a>
* <a href="https://github.com/polygonix/GhostBacker" target="_blank">Создание шаблонов </a>

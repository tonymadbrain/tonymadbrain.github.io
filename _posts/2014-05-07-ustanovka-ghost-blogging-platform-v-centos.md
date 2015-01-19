---
title: Установка Ghost blogging platform в CentOS
author: madman
layout: post
permalink: /ustanovka-ghost-blogging-platform-v-centos/
categories:
  - CentOS
  - root
tags:
  - blog
  - CentOS
  - ghost
  - nginx
---
<a href="http://res.cloudinary.com/doam-ru/image/upload/v1409069989/ghost-blogging-platform_abzrkg.jpg" rel="lightbox[789]" title="ghost-blogging-platform"><img class="aligncenter wp-image-802" src="http://res.cloudinary.com/doam-ru/image/upload/v1409069989/ghost-blogging-platform_abzrkg.jpg" alt="ghost-blogging-platform" width="694" height="366" /></a>

### Что такое Ghost?

О данном проекте писали на хабре, как минимум [здесь][1]. Так что, много рассказывать не собираюсь. Выделю самое главное:

  * Это платформа для блоггинга, как, например, <a href="http://wordpress.org" target="_blank">WordPress</a>
  * Это очень быстрый движок, потому, что работает на <a href="http://nodejs.org/" target="_blank">node.js</a>
  * Простой и удобный интерфейс
  * Собственный магазин с платными и бесплатными шаблонами

<!--more-->

### Установка Ghost в CentOS

Системные требования:

<pre>yum groupinstall -y "Development Tools"
yum install -y wget
</pre>

Устанавливаем Node.js

<pre>wget http://nodejs.org/dist/node-latest.tar.gz
tar -xzf node-latest.tar.gz
cd node-v*
./configure  
make  
make install
ln -s /usr/local/bin/node /usr/bin/node
ln -s /usr/local/bin/npm /usr/bin/npm</pre>

**Установка Ghost**

<pre>mkdir -p /var/www/ghost
cd /var/www/ghost
wget https://ghost.org/zip/ghost-latest.zip 
unzip ghost-latest.zip  
npm install --production</pre>

Создание пользователя Ghost

<pre>useradd ghost
chown ghost:ghost /var/www/ghost/ -R</pre>

Запуск Ghost в режиме разработчика

<pre>npm start</pre>

Таким образом мы запустили движок в режиме разработчика/отладки (dev) на localhost’е на порту 2368 (127.0.0.1:2368)

Можно посмотреть результат, открыв в браузере адрес <http://127.0.0.1:2368>

### Дальнейшая настройка Ghost

Естественно нам необходимо две вещи, чтобы блог открывался по доменному имени и на 80 порту.

В папке с ghost есть два файла config.example.js и config.js. (если второго нет, необходимо переименовать первый или скопировать). Считывается config.js.

> Заметка: в конфигурационном файле есть несколько блоков настроек, dev, production и testing. В зависимости от того в каком режиме вы будете запускать сервер такие настройки и будут применены.

Итак, чтобы решить задачу с доменным именем и портом, можно изменить настройки в конфиге самого ghost’а, а можно установить nginx и через него проксировать запросы в node.js.

Тут, на мой взгляд, кому как удобнее.

В конфиге ghost, нас интересует следующее:

<pre>var path = require('path'),
config;

config = {
// ### Development **(default)**-  настройки для запуска в режиме DEV
development: {
// The url to use when providing links to the site, E.g. in RSS and email.
url: 'http://ghost.mysite.com', <strong>//Адрес который будет слушать встроенный веб-сервер</strong>
database: {
client: 'sqlite3',
connection: {
filename: path.join(__dirname, '/content/data/ghost-dev.db')
},
debug: false
},

server: {
// Host to be passed to node's `net.Server#listen()`
host: '0.0.0.0', <strong>//По умолчанию здесь указан </strong><strong>localhost</strong><strong>, если поставить 0.0.0.0</strong>
<strong>//будут слушаться все интерфейсы, либо можно выставить определенный.</strong>
// Port to be passed to node's `net.Server#listen()`, for iisnode set this to `process.env.PORT`
port: '2368' <strong>// Здесь задается порт, нас интересует 80.</strong>
},
paths: {
contentPath: path.join(__dirname, '/content/')
}
},

// ### Production – настройки для запуска в режиме Production
<strong>//Для продакшн, настройки точно такие же, однако не забывайте их поменять</strong>
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
},</pre>

### Настройка Ghost с использованием Nginx

При этом мы сохраняем дефолтные настройки Ghost и запускаем сервер на localhost на порту 2368.

### Установка Nginx

Добавляем репозиторий Nginx

<pre>vim /etc/yum.repos.d/nginx.repo</pre>

В файл добавляем текст:

<pre>[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1</pre>

Сохраняем файл, устанавливаем Nginx, запускаем его и добавляем в автозагрузку, следующими командами:

<pre>yum install nginx -y
service nginx start
chkconfig nginx on</pre>

Далее создаем конфиг виртуального хоста для нашего Ghost сервера:

<pre>vim /etc/nginx/conf.d/ghost.mysite.com.conf</pre>

Со следующим содержимым:

<pre>server {
        listen 80;
        server_name yourdomain.com www.yourdomain.com;
        location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:2368;
        }
}
</pre>

Для применения настроек выполняем команду:

<pre>service nginx reload</pre>

Вот и все, теперь ваш блог на движке Ghost доступен по адресу yourdomain.com на 80 порту.

Материалы по теме:

  * <a href="https://ghost.org/" target="_blank">Официальный сайт Ghost </a>
  * <a href="http://marketplace.ghost.org/" target="_blank">Магазин шаблонов</a>
  * <a href="https://github.com/polygonix/GhostBacker" target="_blank">Создание шаблонов </a>

Статья позаимствована в <a href="http://www.nginxtips.ru/ustanovka-ghost-blogging-platform-v-centos/" target="_blank">nginxtips.ru</a>

 [1]: http://habrahabr.ru/post/197546/
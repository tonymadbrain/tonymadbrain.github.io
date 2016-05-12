---
layout: post
title: Установка LiveStreet CMS
date: '2014-08-12 05:30:40'
excerpt: ""
---

![alt](https://farm8.staticflickr.com/7422/16514984271_39ac810ec9_o.png)
Заинтересовался данной <a href="http://livestreetcms.ru/" target="_blank">CMS</a>, при запросе в гугле "livestreet cms + nginx" попал  вот на <a href="http://livestreet.ru/blog/dev_documentation/10626.html" target="_blank">такую статью</a>. Она мне не совсем подошла, так как, как минимум я использую CentOS/RHEL. Так что внесу свою лепту.
<h3>Тестовая среда</h3>
Тестирую я обычно на отдельном сервере, на котором уже готова среда nginx+php-fpm+mysql. По мимо стандартных репозиториев, используются epel, nginx и remi. Установленные пакеты версий:
<pre>
# nginx -v
nginx version: nginx/1.6.1
# mysql -V
mysql  Ver 14.14 Distrib 5.5.37, for Linux (x86_64) using readline 5.1
# php -v
PHP 5.4.28 (cli) (built: May  2 2014 19:09:57)
Copyright (c) 1997-2014 The PHP Group
Zend Engine v2.4.0, Copyright (c) 1998-2014 Zend Technologies
</pre>
Php-fpm работает через сокет.
Далее пойдем по шагам из указанного выше мануала.

<h3>Конфигурируем nginx</h3>
Я никогда не удаляю дефолтный конфиг, только меняю имя с default.conf на default. В RHEL более удобная структура конфигов чем в Debian like, поэтому я делаю просто:
<pre># vim /etc/nginx/conf.d/live.domain.org.conf</pre>
В названиях конфигов я использую доменное имя и .conf чтобы он применился при релоаде веб-сервера.
Содержимое конфига в моем случае не претерпело сильных изменений:
<pre>
server {
        listen 80;
        server_name live.domain.org;

        access_log /var/log/nginx/access_log;
        error_log /var/log/nginx/error_log;

        root /var/www/live;
        index index.php;

        location / {
                try_files $uri $uri/ /index.php?q=$uri&$args;
        }

        location ~ \.php {
                fastcgi_pass  unix:/var/run/php-fpm/php-fpm.sock;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }

        location ~ \.(tpl|xml|log)$ {
                deny all;
        }
}
</pre>
Перезагружаем nginx: - автор немного перепутал, либо не придает этому значения. Между restart и reload есть принципиальная разница.
<pre>service nginx reload</pre>
<h3>Подготавливаемся к установке Livestreet</h3>
Для каждого проекта я выделяю отдельный каталог в папке /var/www, таким образом путь до файлов сайта будет /var/www/live.
В описанной в мануале проверке работы php, в моем случае, нет смысла. Так что я пропущу этот шаг.
<h3>Настраиваем mysql</h3>
Вот тут наверно у меня возникли самые большие разногласия с автором.
<pre># mysql -uroot -p</pre>
Подключаемся к консоли управления mysql.
<pre>CREATE DATABASE live CHARACTER SET utf8 COLLATE utf8_general_ci;</pre>
Создаем новую БД.
<pre>> GRANT SELECT,LOCK TABLES,CREATE TEMPORARY TABLES,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX ON live.* TO 'liveuser'@'localhost' identified by 'passwd';</pre>
Давать все привилегии нет смысла, перечисленных выше достаточно, как показывает практика, для работы любой CMS.
<pre>> flush privileges;</pre>
Чтобы применить изменения в политиках доступа, т.е. чтобы новый пользователь смог подключиться к БД, необходимо выполнить команду выше (и выполнять всегда, когда вы производите любые действия по изменению прав доступа).
<pre>> \q</pre>
Ну и самое печальное, люди продолжают использовать exit, когда есть \q.
Кстати, сейчас заметил, что у автора мануала какая-то странная нумерация - 4.0, 4.1, 4. (?)
<h3>Установка LS</h3>
Ну с этим трудностей возникнуть не должно, единственное, что лучше указать ссылку на список релизов, а не на конкретную версию.
В общем-то, скачали, распокавали, в браузере открыли http://live.domain.org/install и выполнили установку. Удаляем папку install.
<h3>Sphinx</h3>
Sphinx нужен чтобы работал поиск по сайту, были некоторые проблемы с mysql и типом таблиц InnoDB, но сейчас все работает (имеется ввиду ОС RHEL).
Установка
<pre># yum install sphinx</pre>
Конфиг для CentOS имеет немного другой вид.
<pre>
#cp /etc/sphinx/sphinx.conf /etc/old_sphinx.conf
#vim /etc/sphinx/sphinx.conf
</pre>
У меня конфиг получился вот такой:
<pre>
## Конфигурационный файл Sphinx-а для индексации LiveStreet
#######################
# Описываем индексы
#######################
# Источник-родитель для всех остальных источников. Здесь указываются параметры доступа
# к базе данных сайта
source lsParentSource
{
        type            = mysql
        sql_host        = localhost
        sql_user        = user
        sql_pass        = pass
        sql_db          = db_name
        sql_port        = 3306
        # Для ускорения работы прописываем путь до MySQL-го UNIX-сокета (чтобы
        # операции с БД происходили не через TCP/IP стек сервера)
        #sql_sock        = /var/run/mysqld/mysqld.sock
        sql_sock = /var/lib/mysql/mysql.sock
        mysql_connect_flags     = 32 # 32- включение сжатие при обмене данными с БД
        # Включам нужную кодировку соединения и выключаем кеш запросов
        sql_query_pre                   = SET NAMES utf8
        sql_query_pre                   = SET SESSION query_cache_type=OFF
}
# Источник топиков
source topicsSource : lsParentSource
{
        # запрос на получения данных топиков
        sql_query               = \
                SELECT t_fast.topic_id, t_fast.topic_title, UNIX_TIMESTAMP(t_fast.topic_date_add) as topic_date_add, \
                tc.topic_text, t_fast.topic_publish \
                FROM live_topic as t_fast, live_topic_content AS tc \
                WHERE t_fast.topic_id=tc.topic_id AND t_fast.topic_id>=$start AND t_fast.topic_id<=$end
        # запрос для дробления получения топиков на неколько итераций
        sql_query_range         = SELECT MIN(topic_id),MAX(topic_id) FROM live_topic
        # сколько получать объектов за итерацию
        sql_range_step          = 1000
        # Указываем булевый атрибут критерия "топик опубликован". Для возможности указания этого критерия при поиске
        sql_attr_uint = topic_publish
        # Атрибут даты добавления, типа "время"
        sql_attr_timestamp      = topic_date_add
        # мульти-аттрибут "теги топика"
        sql_attr_multi  = uint tag from query; SELECT topic_id, topic_tag_id FROM live_topic_tag
        sql_ranged_throttle     = 0
}
# Источник комментариев
source commentsSource : lsParentSource
{
        sql_query               = \
                        SELECT comment_id, comment_text, UNIX_TIMESTAMP(comment_date) as comment_date, comment_delete \
                        FROM live_comment \
                        WHERE target_type='topic' AND comment_id>=$start AND comment_id<=$end AND comment_publish=1
        sql_query_range         = SELECT MIN(comment_id),MAX(comment_id) FROM live_comment
        sql_range_step          = 5000
        sql_attr_uint = comment_delete
        sql_attr_timestamp      = comment_date
}
#######################
# Описываем индексы
#######################
index topicsIndex
{
        # Источник, который будет хранить данный индекса
        source                  = topicsSource
        path                    = /var/lib/sphinx/topicIndex
        # Тип хранения аттрибутов
        docinfo                 = extern
        mlock                   = 0
        # Используемые морфологические движки
        morphology = stem_enru
        # Кодировака данных из источника
        charset_type            = utf-8
        # Из данных источника HTML-код нужно вырезать
        html_strip                              = 1
        html_remove_elements = style, script, code
}
# Индекс комментариев
index commentsIndex
{
        source                  = commentsSource
        path                    = /var/lib/sphinx/commentsIndex
        docinfo                 = extern
        mlock                   = 0
        morphology = stem_enru
        charset_type            = utf-8
        # Из данных источника HTML-код нужно вырезать
        html_strip                              = 1
        html_remove_elements = style, script, code
}
#######################
# Настройки индексатора
#######################
indexer
{
        # Лимит памяти, который может использавать демон-индексатор
        mem_limit                       = 128M
}
#######################
# Настройка демона-поисковика
#######################
searchd
{
        # Адрес, на котором будет прослушиваться порт
        #address                         = 127.0.0.1
        listen = 127.0.0.1
        # Ну и собственно номер порта демона searchd
        port                            = 3312
        # Лог-файл демона
        log                                     = /var/log/sphinx/searchd.log
        # Лог поисковых запросов. Если закомментировать,то логировать поисковые строки не будет
        query_log                       = /var/log/sphinx/query.log
        # Время в секундах, которое ждет демон при обмене данными с клиентом. По исчерпании происходит разрыв коннекта
        read_timeout            = 5
        # Максимальное количество одновременно-обрабатываемых запросов. 0 означает дофига, а точнее без ограничения
        max_children            = 100
        # Файл, в который сохраняется PID-процесса при запуске
        pid_file                        = /var/log/sphinx/searchd.pid
}
</pre>
"Настраиваем под себя sql_user, sql_pass, sql_db. Не забываем поменять стандартный «prefix_» на наш (вы же при установке действительно выбрали себе уникальный префикс для таблиц?)"
Здесь, автор оригинальной статьи, подразумевает что в строчках, например:
<pre>
sql_query_range         = SELECT MIN(topic_id),MAX(topic_id) FROM PREFIX_topic
</pre>
Нужно заменить PREFIX, на ваш префикс, который вы указали при инсталяции CMS.
Далее нужно созать индексы:
<pre>
# /usr/bin/indexer --all
</pre>
Теперь запускаем:
<pre>
# service searchd start
</pre>
И добавляем в автозагрузку:
<pre>
# chkconfig searchd on
</pre>
И настроим автоматическую индексацию:
<pre>
# crontab -e
</pre>
Дописываем в конец:
<pre>
12 */3 * * *  /usr/bin/indexer --rotate topicsIndex > /dev/null 2>&1
*/50 * * * *  /usr/bin/indexer --rotate commentsIndex > /dev/null 2>&1
</pre>
На этом моя настройка заканчивается, хотя вроде я еще memcache настраивал, потом допишу, если да.
И стоит упомянуть, что это актуально для версии 1.0.3, а разработчики готовят релиз версии 2, и там скорее всего будут изменения.

---
layout: post
title: Деплой приватных SSL ключей с помощью Ansible
excerpt: ""
tags:
  - Ansible
  - Tutorial
date: 2016-11-03T10:49:52+03:00
---

<br>
<img src="https://farm6.staticflickr.com/5488/30713598396_b204277003_o.png">
<br>
<br>

{% include _toc.html %}

Когда используете систему для управления конфигурацией как Ansible или любую другую, рано или поздно вы столкнетесь с доставкой/выкладкой/деплоем приватных ключей SSL. Деплой публичных SSL cертификатов не является проблемой безопасности, тогда как выкладка приватных ключей очень критичный момент.

> От переводчика: <a href="https://blog.confirm.ch/deploying-ssl-private-keys-with-ansible/" target="_blank">Оригинал статьи</a>. В моем случае была задача раскладывать по агентам приватные SSH ключи, чтобы они могли "ходить" в git репозиторий.

### Проблема с приватными ключами

Слово *приватный* уже говорит о многом, потому что приватные ключи должны оставаться приватными в любом случае. Но если ваше рабочее окружение содержит много инструментов автоматизации и управления конфигурацией, вы можете задаться вопросом:

> Как я могу деплоить и конфигурировать зашифрованное с помощью SSL приложение автоматически?

К счастью в Ansible есть несколько вариантов для этого.

### Вариант 1: Проверять права на файлы

Наиболее простой вариант это пропустить сам процесс доставки сертификатов и просто проверять что файлы находятся на своих местах и права на доступ корректные:

{% highlight yaml %}
# tasks/main.yml
---
- name: make sure SSL certificate is existing and secured
  file:
    state:  file
    path:   '{{ item.path }}'
    owner:  root
    group:  root
    mode:   '{{ item.mode }}'
  with_items:
    - path: /path/to/my/cert.pem
      mode: '0644'
    - path: /path/to/my/key.pem
      mode: '0600'

{% endhighlight %}

Вы увидите сообщение об ошибке во время деплоя вашего приложения если сертификат не установлен. Конечно же Ansible поправит права доступа в том случае, если вы установили сертификат вручную но забыли выставить права. К сожалению, сертификаты в этом случае придется устанавливать вручную.

### Вариант 2: Копирование сертификатов с помощью Ansible по требованию

Может очень раздражать тот факт, что у вас деплой на сервера и все задачи автоматизированы, кроме долбанных сертификатов. Так что есть обходной путь, с задачей (task) "по требованию" в Ansible:

{% highlight bash %}
# Copy certificate
$ ansible -m copy -a "src=certificate.pem dest=/path/to/my/certificate.pem owner=root group=root mode=0644" webservers

# Copy private key
$ ansible -m copy -a "src=key.pem dest=/path/to/my/key.pem owner=root group=root mode=0600" webservers
{% endhighlight %}

Используя выше указанные команды вы просто копируете ваши сертификаты и приватный ключ на все необходимые вебсерверы. В зависимости от вашей конфигурации Ansible вам могут потребоваться ключи `-i`(inventory) и `-s`(sudo).

> От переводчика: в новых версиях Ansible нужно использовать флаг `--become` вместо `-s`

К сожалению, вы все еще должны копировать сертификаты на вашу Ansible ноду и выполнять указанные выше команды вручную перед тем как запускать деплой приложения. А после деплоя нужно быть уверенным что вы удалили сертификаты с управляющей машины или хотя бы устанавливать корректные права доступа, чтобы только авторизированные пользователи могли читать их.

### Вариант 3: Деплой сертификатов после запроса переменных

Тем временем, есть альтернативный способ, который смешивает два предыдущих. Вы все еще используете задачу из [варианта 1](#section-1), но вместо модуля `file` используете модуль `copy` из [варианта 2](#ansible--). Тогда вместо указания постоянного `src` будут использоваться переменные:

{% highlight yaml %}
# tasks/main.yml
---
- name: make sure SSL certificate is existing and secured
  copy:
    src:    '{{ itme.src }}'
    path:   '{{ item.path }}'
    owner:  root
    group:  root
    mode:   '{{ item.mode }}'
  with_items:
    - src:  '{{ ssl_certificate }}'
      path: /path/to/my/cert.pem
      mode: '0644'
    - src:  '{{ ssl_private_key }}'
      path: /path/to/my/key.pem
      mode: '0600'

{% endhighlight %}

Затем, спрашиваем у пользователя ввод путей сертификатов и приватного ключа в плейбуке.

{% highlight yaml %}
# play.yml
---
- hosts:
  roles:
    - my_app
  vars_prompt:
    ssl_certificate: Enter path to SSL certificate
    ssl_private_key: Enter path to SSL private key

{% endhighlight %}

Это довольно безопасный вариант при условии что вы удаляете сертфикаты с управляющей ноды после деплоя. Однако он не полностью автоматизирован, потому что необходим ввод параметров от пользователя.

### Вариант 4: Деплой сертификатов с помощью Ansible play

Конечно же автоматизированный деплой доступов или приватных ключей очень крутая штука, хотя безопасность очень важна. Вы не должны даже думать о том чтобы хранить эти данные в <u>незащищенном</u> виде в вашем SCM репозитории, как это делают <a href="http://www.securityweek.com/github-search-makes-easy-discovery-encryption-keys-passwords-source-code" target="_blank">некоторые</a>. Просто не думайте об этом - не делайте этого - никогда - серьезно!

В Ansible вы можете деплоить сертификаты и приватные ключи автоматически и при этом хранить их в репозитории. Но, как было сказано ранее, не стоит хранить их незащищенными! Ansible внедрил <a href="http://docs.ansible.com/ansible/playbooks_vault.html" target="_blank">Vault</a> в версии 1.5, который добавляет функционал для сохранения вашей секретной информации приватной. Ваулты (Vaults) это как файлы переменных только зашифрованные.

В начале создайте новый ваулт или отредактируйте существующий:

{% highlight bash %}
# Create a new vault
$ ansible-vault create certificate.yml

# Edit an existing vault
$ ansible-vault edit certificate.yml
{% endhighlight %}

Теперь добавьте секретные ключи или сертификаты как переменные:

{% highlight yaml %}
# certificate.yml
---
ssl_certificate: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----

ssl_private_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
{% endhighlight %}

Убедитесь что ваулт загружен, либо через `vars_files` директиву в плейбуке, либо через `include_vars` стейт в role/tasks:

{% highlight yaml %}
# play.yml
---
- hosts:
  roles:
    - my_app
  vars_files:
    - vars/certificate.yml

{% endhighlight %}

{% highlight yaml %}
# tasks/main.yml

---
- include_vars: certificate.yml

{% endhighlight %}

Установим сертификат и приватный ключ с помощью модуля `copy`:

{% highlight yaml %}
# tasks/main.yml
---
- name: make sure SSL certificate is installed
  copy:
    content: '{{ ssl_certificate }}'
    dest: /path/to/my/cert.pem
    owner: root
    group: root
    mode: 0644

- name: make sure SSL private key is installed
  copy:
    content: '{{ ssl_private_key }}'
    dest: /path/to/my/key.pem
    owner: root
    group: root
    mode: 0600
  no_log: true

{% endhighlight %}

Теперь, при запуске команды `ansible-playbook` вы должны добавить ключ `--ask-vault-pass` или `--vault-password-file FILE`:

{% highlight bash %}
$ ansible-playbook play.yml --ask-vault-pass
{% endhighlight %}

Таким образом вы можете деплоить ваши сертификаты внутри плейбука. В файлах переменных круто то, что они могут храниться где угодно, так что вы не обязаны хранить все все Ansibel SCM репозитории. Конечно, если вам необходимо иметь портативную (portable) версию Ansible, можете хранить ваулты в репозитории или любой другой расшаренной системе хранения. Но если вы используете только одну управляющую ноду, легче хранить ваулты вне репозитория.

### Заключение

Самый безопасный способ хранить ваши ключи действительно приватными это варианты 1, 2 и 3, тогда как это может быть очень нудным и раздражающим.

Если вы ищете способ деплоить секретную информацию как приватные ключи через Ansible автоматически, вам нужен вариант 4. Вы должны будете хранить данные в Ansible SCM репозитории, но по крайней мере они будут зашифрованы.









---
title: Сброс пароля суперпользователя в linux
layout: post
permalink: /sbros-parolya-superpol-zovatelya-v-linux/
tags:
  - Hack
  - Linux
  - Password
  - RHCE
  - root
  - Trick
---
<a href="http://doam.ru/wp-content/uploads/2014/10/root.png" rel="lightbox[981]" title="root"><img class="aligncenter size-full wp-image-983" src="http://doam.ru/wp-content/uploads/2014/10/root.png" alt="root" width="800" height="480" /></a>Сейчас для меня актуальна тема самостоятельной подготовки к сдаче RHCSA/RHCE, поэтому в моем браузере открыты несколько вкладок на эту тему. Дабы отсеять ненужное, решил написать заметку.

Есть вот такая <a href="http://open-os.ru/zabyl-parol-ot-root/" target="_blank">ссылка </a>, и решение, которое приводится там, мне не знакомо. Я попробовал его на Fedora 20 и не получилось. Поэтому в рамках новой рубрики &#171;Самостоятельная подготовка к RHCE&#187;, первая статья.

Для сброса рутового пароля, необходимо:

<!--more-->

1. в grub выбрать нашу загрузочную запись, нажать &#171;e&#187; (открыть на редактирование)

2. в конце строки с загрузкой ядра добавить

<pre>init=/bin/sh</pre>

3. запустить загрузку, клавишами Ctrl+x или F10 (или другими если они описаны в меню).

4. дальше можно пробовать выполнить

<pre># passwd root</pre>

5. если встречаете ошибку

<pre>passwd: Authentication token manipulation error</pre>

стоит попробовать:

<pre>mount -rw -o remount /</pre>

6. снова пробуем выполнить

<pre># passwd root</pre>

Я еще не сталкивался с тем, чтобы эта схема не сработала.

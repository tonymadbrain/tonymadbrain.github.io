---
layout: post
title: Загрузка резервных копий OpenVZ из Proxmox в Yandex.Disk
excerpt: "Заметки из redmine"
permalink: /upload_proxmox_backups_to_yandex_disk/
tags:
  - Proxmox
  - Openvz
  - YandexDisk
date: 2016-10-23T14:05:30+03:00
---

> У меня в redmine лежат заметки, к которым не обращаюсь, но выглядят они полезными, поэтому перенесу их сюда, как бы в архив.

<a href="https://disk.yandex.ru/" target="_blank">Яндекс диск</a> поддерживает загрузку по протоколу WebDAV. Логика будет такая:

* Бекапы в proxmox делаются каждую ночь в 00:00.
* Скрипт по крону в 01:00 каждую ночь грузит эти бекапы на диск

{% highlight php %}
# yandex_disk_webdav_backup.php

$WebDAV = [
  'login'=>'login',
  'password'=>'password',
  'url'=>'https://webdav.yandex.ru/proxmox_backups/',
];

$dir = '/var/back_to_up/vz/dump';
$files_to_send = [];
$f = scandir($dir);

foreach ($f as $file){
  if(preg_match('/\.(tar)/', $file)){
    //echo $file.'\n';
    $files_to_send []= $file;
  }
}

$date = date('Y-m-d');
$errors = [];
$success = [];

foreach ($errors as $e) {
  echo 'Ошибка: ' . $e . "\n";
}

echo "\n";

foreach ($success as $s) {
  echo 'ОК: ' . $s . "\n";
}
echo "\n";

echo "Следующие файлы будут загружены:\n";

foreach ($files_to_send as $f) {
  echo $f . "\n";
}

echo "\n";

if (!empty($files_to_send)) {
  foreach ($files_to_send as $file) {
    echo shell_exec("curl --user {$WebDAV['login']}:{$WebDAV['password']} -T \"$dir/$file\" {$WebDAV['url']}") . "\n";//если ругается на сертификат, можно добавить ключ -k
  }
}
?>
{% endhighlight %}

Примечания: папка должна быть создана на Яндекс диске, иначе все будет "запихнуто" в один файл.

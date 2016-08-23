---
title: Проблема с PGP ключами в Proxmox
layout: post
permalink: /problem_with_pgp_keys_in_proxmox/
redirect_from:
  - /problema-s-pgp-klyuchami-v-proxmox/
  - /problem-with-pgp-keys-in-proxmox/
excerpt: ""
tags:
  - Debian
  - Fix
  - PGP
  - Proxmox
  - Upgrade
---

<br>
<img src="https://farm1.staticflickr.com/651/21033062193_2ff1a1cefd_o.png">
<br>
<br>

Тем у кого нет платной подписки Proxmox, с недавнего времени приходится использовать другой репозиторий, правда, по-прежнему поддерживаемый. При попытке обновления я полез гуглить и наткнулся на эту информацию, в итоге, наворотил чего-то с репозиториями и PGP ключами, плюнул на все и бросил эту ноду. Когда появилась новость об уязвимости в Bash, вопрос обновления встал остро и нужно было что-то делать.

Итак, при попытке сделать

{% highlight bash %}
$ apt-get update
{% endhighlight %}

я получал:

{% highlight bash %}
Get:1 http://ftp.debian.org wheezy Release.gpg [1 655 B]
Hit http://download.proxmox.com wheezy Release.gpg
Hit http://ftp.debian.org wheezy Release
Hit http://download.proxmox.com wheezy Release
Ign http://ftp.debian.org wheezy Release
Ign http://ftp.debian.org wheezy/main Sources/DiffIndex
Get:2 http://security.debian.org wheezy/updates Release.gpg [836 B]
Ign http://ftp.debian.org wheezy/contrib Sources/DiffIndex
Ign http://ftp.debian.org wheezy/main amd64 Packages/DiffIndex
Ign http://ftp.debian.org wheezy/contrib amd64 Packages/DiffIndex
Hit http://security.debian.org wheezy/updates Release
Ign http://security.debian.org wheezy/updates Release
Hit http://ftp.debian.org wheezy/contrib Translation-en
Ign http://security.debian.org wheezy/updates/main Sources/DiffIndex
Hit http://ftp.debian.org wheezy/main Translation-en
Hit http://ftp.debian.org wheezy/main Sources
Hit http://ftp.debian.org wheezy/contrib Sources
Ign http://security.debian.org wheezy/updates/contrib Sources/DiffIndex
Hit http://ftp.debian.org wheezy/main amd64 Packages
Hit http://ftp.debian.org wheezy/contrib amd64 Packages
Ign http://security.debian.org wheezy/updates/main amd64 Packages/DiffIndex
Ign http://security.debian.org wheezy/updates/contrib amd64 Packages/DiffIndex
Ign http://ftp.debian.org wheezy/contrib Translation-en_US
Hit http://security.debian.org wheezy/updates/contrib Translation-en
Ign http://ftp.debian.org wheezy/main Translation-en_US
Hit http://security.debian.org wheezy/updates/main Translation-en
Hit http://security.debian.org wheezy/updates/main Sources
Hit http://security.debian.org wheezy/updates/contrib Sources
Hit http://security.debian.org wheezy/updates/main amd64 Packages
Hit http://security.debian.org wheezy/updates/contrib amd64 Packages
Ign http://security.debian.org wheezy/updates/contrib Translation-en_US
Ign http://security.debian.org wheezy/updates/main Translation-en_US
Fetched 2 491 B in 3s (644 B/s)
W: GPG error: http://ftp.debian.org wheezy Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 8B48AD6246925553 NO_PUBKEY 6FB2A1C265FFB764
W: GPG error: http://security.debian.org wheezy/updates Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 8B48AD6246925553
W: Failed to fetch http://download.proxmox.com/debian/dists/wheezy/Release Unable to find expected entry 'pve-no-subscription/source/Sources' in Release file (Wrong sources.list entry or malformed file)

E: Some index files failed to download. They have been ignored, or old ones used instead.
{% endhighlight %}

Исправляется следующим образом:

**Дергаем нужные ключи**

{% highlight bash %}
$ gpg --keyserver subkeys.pgp.net --recv-keys 8B48AD6246925553
gpg: requesting key 46925553 from hkp server subkeys.pgp.net
gpg: key 46925553: public key "Debian Archive Automatic Signing Key (7.0/wheezy) &lt;ftpmaster@debian.org&gt;" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)

$ gpg --keyserver subkeys.pgp.net --recv-keys 6FB2A1C265FFB764
gpg: requesting key 65FFB764 from hkp server subkeys.pgp.net
gpg: key 65FFB764: public key "Wheezy Stable Release Key &lt;debian-release@lists.debian.org&gt;" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
{% endhighlight %}

**Добавляем их**

{% highlight bash %}
$ gpg -a --export 6FB2A1C265FFB764 | sudo apt-key add -
OK
$ gpg -a --export 8B48AD6246925553 | sudo apt-key add -
OK
{% endhighlight %}

После этого, правда, я получил ошибку:

{% highlight bash %}
W: Failed to fetch http://download.proxmox.com/debian/dists/wheezy/Release  Unable to find expected entry 'pve-no-subscription/source/Sources' in Release file (Wrong sources.list entry or malformed file)
{% endhighlight %}

Фикс которой заключается в добавлении `[arch=amd64]` в строку:

{% highlight bash %}
deb [arch=amd64] http://download.proxmox.com/debian wheezy pve-no-subscription
{% endhighlight %}

Не анализировал сложившуюся ситуацию и не разобрался полностью в том, как её убрать, но это было решениям для меня.

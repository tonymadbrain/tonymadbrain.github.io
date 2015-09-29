---
layout: post
title: "Алиасы для Git"
permalink: /2015-04-29-aliases_for_git/
date: 2015-04-29T00:12:44+03:00
tags:
  - Git
---

Стандартные команды гита довольно просты, и, кажется, что использовать их не сложно, пока не попробуешь алиасы.
Два символа ```co``` явно быстрее вводить чем ```checkout``` да и вероятность опечататься гораздо меньше.

<br>
<img src="https://farm1.staticflickr.com/715/21620792628_a49b7b3171_o.jpg">
<br>
<br>

Лично я использую следующие алиасы:

{% highlight bash %}
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
git config --global alias.lg 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
{% endhighlight %}

Последние два, кстати, делают вывод лога более читабельным и понятным (в общем крутым).

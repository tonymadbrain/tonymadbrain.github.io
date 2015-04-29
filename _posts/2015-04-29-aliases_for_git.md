---
layout: post
title: "Алиасы для Git"
permalink: /2015-04-29-aliases_for_git/
date: 2015-04-29T00:12:44+03:00
---

{% highlight bash %}
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
{% endhighlight %}
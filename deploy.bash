#!/bin/bash

#BLOG_PATH="/Users/madbrain/projects/tonymadbrain.github.io"
DATE=`date +%Y_%m_%d_%H:%M:%S`
git add .
git ci -m "$DATE changes"
git push -u private blog
if jekyll build
then
  git checkout master
  mv $PWD/_site /tmp/temp_blog
  rm -rf $PWD/* 
  mv /tmp/temp_blog/* $PWD/ 
  rm -rf /tmp/temp_blog
  git add .
  git commit -am "Deploy site $DATE"
  git push -u origin master
  git push -u private master
  git checkout blog
else
  echo "Errors carl!"
  exit 1
fi

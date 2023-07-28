---
title: 'Linux Shell 使用alias定义别名'
date: 2022-03-31 09:57:18
tags:
- Linux
categories:
- Linux
---

 

# Linux Shell 使用alias定义别名



在我们使用终端时, 为了提高平时工作效率和减少常用命令过长, 敲起来浪费时间, 可在`/etc/profile`文件中配置`alias`，自定指令的别名

<!--more-->



打开`/etc/profile`配置文件

```shell
vim /etc/profile
```



在文件末尾增加以下配置

```shell
#[alias]

##cd dir##
alias -- -='cd -'  		# 此处意思为输入 - 回车, 相当于执行 cd -, 快速切换回上一个目录(两个目录之间来回切换)
alias ..='cd ..'
alias e='exit'
alias 'www'='cd $www' 	# $www是个人配置的环境变量, $www指向的是工作目录

##vim file##
alias 'vp'='vim /etc/profile'
alias 'vv'='vim /etc/vimrc'
alias 'sp'='source /etc/profile'

##git##
alias 'gs'='git status'
alias 'gaa'='git add .'
alias 'gcm'='git commit -m'
alias 'gco'='git checkout'
alias 'gb'='git branch -vvv'
alias 'gd'='git diff'
alias 'cls'='clear'
alias -- --='git checkout -' #此处意思为输入 -- 回车, 相当于执行 git checkout -, 快速切换回上一个分支(两个分支之间来回切换)
alias 'show'='git show'
alias 'push'='git push origin `git branch --show-current`'
alias 'fpush'='git push -f origin `git branch --show-current`' 			#强推
alias 'pull'='git pull origin `git branch --show-current`'
alias 'rpull'='git pull origin `git branch --show-current` --rebase' 	#pull时增加 --rebase参数
alias 'ml'='git log --author=`git config user.name`' 					#查看本人提交的log
alias 'gl'='git log'
alias 'ggl'='git log --graph'
alias 'gglp'='git log --graph --pretty=oneline --abbrev-commit'			#可视化查看分支线的情况
alias 'review'='review() { git status --short | egrep ^*.php | sed "s/^ *//" | egrep ^[^D] | tr -s " "| cut -d" " -f 2 | egrep -v database/migrations | xargs $1;};review'  #列出修改过未提交的php文件
alias 'qq'='review "git checkout"'			#把列出修改过未提交的php文件当做参数 提供给git checkout, 全部撤销

##ssh##
alias 'chuchu'='ssh root@ip'

##Docker##
alias 'dkre'='docker-compose restart'
alias 'dkup'='docker-compose up'
alias 'dkop'='docker-compose stop'
alias 'dkphp'="winpty docker exec -it `docker ps --filter='name=php7' -q` bash" 	#快速进入docker的php7容器
alias 'dkphp5'="winpty docker exec -it `docker ps --filter='name=php5' -q` bash"
```



执行 `source /etc/profile` 重新加载刚修改配置生效

```shell
source /etc/profile
```


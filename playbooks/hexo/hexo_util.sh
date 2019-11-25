#!/usr/bin/env bash
echo "using hexo_util, Welcome! author: liukaitao"
echo "============================================"


read -p "文件名称为："  name

read -p "pull or push:" function

echo "${function}ing, please wait......."

yml="hexo_${function}.yml"

if [ ${function} != "pull" ] && [ ${function} != "push" ];then
	echo "please use pull or push ...."
	exit 0
fi

ansible-playbook $yml --extra-vars="name=$name" 

if [ $function = "pull" ];then
	echo "pull the ${name} dir"
	mkdir ./articles/${name}
fi

echo "hexo_util finished..."
#ansbile-playbook hexo_pull.yml --extra-vars="name=test" -v
#ansible-playbook hexo_push.yml --extra-vars="name=test" -v


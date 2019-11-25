#!/usr/bin/env bash
echo "using hexo_util, Welcome! author: liukaitao"
echo "============================================"

read -p "pull or push:" function

if [ ${function} = "push" ];then
	# 获取最新文件名称
	name=`ls -lt articles/ | awk '{print $9}'|sed -n '2p' |sed 's/'.md'//g'`
	echo "name is ${name}"
elif [ ${function} = "pull" ];then
	read -p "文件名称为："  name
else
	echo "please use pull or push ...."
        exit 0
fi

echo "${function}ing, please wait......."

yml="hexo_${function}.yml"


ansible-playbook $yml --extra-vars="name=$name" 

if [ $function = "pull" ];then
	echo "pull the ${name} dir"
	mkdir ./articles/${name}
	cd ./articles
	vi "${name}.md"
fi

echo "hexo_util finished..."
#ansbile-playbook hexo_pull.yml --extra-vars="name=test" -v
#ansible-playbook hexo_push.yml --extra-vars="name=test" -v


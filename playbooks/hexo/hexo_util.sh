#!/usr/bin/env bash
echo "[INFO] using hexo_util, Welcome! author: liukaitao"
echo "============================================"

read -p "[ANSWER]pull or push:" function

if [ ${function} = "push" ];then
	# 获取最新文件名称
	name=`ls -lt articles/ | awk '{print $9}'|sed -n '2p' |sed 's/.md//g;/^$/d'`
	echo "[INFO] name is ${name}"
	read -p "[ANSWER] Are you sure: (yes or not)" answer
	if [ ${answer} = "yes" ] || [ -z ${answer} ] ;then
		echo "[INFO] get it !"	
	else 
		read -p "[ANSWER] 文件名称: " name
	fi
elif [ ${function} = "pull" ];then
	read -p "[ANSWER] 文件名称为："  name
else
	echo "[INFO] please use pull or push ...."
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


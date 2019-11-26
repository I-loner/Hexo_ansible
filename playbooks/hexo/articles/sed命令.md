---
title: sed命令
tags:
  - linux
categories:
  - linux
  - shell
top: 100
date: 2019-11-26 09:23:15
---

# `sed`命令
`sed`处理文本时候是**逐行处理的**,读到匹配行就根据指令操作,不匹配就跳过

# 语法
1. 命令行指定`sed`指令对文本处理: `sed` + 选项 '指令' 文件
2. 把`sed`指令保存在文件,将文件作为参数进行调用: `sed`+ 选项 -f 含`sed`指令的文件

# 常用选项:
* `-e` 告诉`sed`将下一个参数解析为 `sed` 指令, 在命令中默认
* `-f` 后跟保存了`sed`指令文件
* `-n` 只显示处理过的行
* `-i` '指令参数' 'file' 修改file文件，而不是输出到终端

# 编辑指令参数
* `1,3` 1至3行  `,`为至的意思
* `^str` 以str开头, `str$` 以str结尾  `^$`空行
* `/xxxx/` 表示匹配xxxx内容
* `/123\|abc/`  `|`或者,但是需要转义
* `1~2d`  第一个数字-->第几行, `~`后数字-->不长

# `sed`中编辑命令
## `a`追加 向匹配行后面插入内容  
## `i`插入 向匹配行前插入内容
## `c`更改 更改匹配行内容
## `d`删除 删除匹配内容
## `p`打印 打印出匹配内容,通常与`-n`选项合用
## `=` 用来打印被匹配行的行号
## `n`读取下一行
## `r,w` 读和写编辑命令, `r`用于将内容读入文件, `w`用于将匹配内容写入文件中
## `g`匹配全部
## 向文件中添加或插入行
```shell
sed '3ahello' 1.txt   # 向第三行后面添加hello, 3表示行号

sed '/123/ahello' 1.txt # 向 内容123后面 添加hello,如果文件中有多行包括123，则每一行后面都会添加

sed '$ahello' 1.txt     # 在最后一行添加hello

sed '3ihello' 1.txt     # 第三行前插入hello

sed '/123/ihello' 1.txt     # 在包含123内容的行之前插入hello, 如果多行包含,则每一行前面都添加

sed '$ihello' 1.txt     #最后一行前插入hello
```

## 更改文件中指定的行
```shell
sed '1chello' 1.txt     # 将文件1.txt的第一行替换为hello, 1为行号

sed '/123/chello' 1.txt     # 将包含123的行替换为hello

sed '$chello'  1.txt  #将最后一行替换为hello
```
## 删除文件中的行
```shell
sed  '4d'  1.txt    #删除第四行

sed '1~2d' 1.txt    #从第一行开始删除，每隔2行就删掉一行，即删除奇数行

sed   '1,2d'  1.txt   #删除1~2行

sed  '1,2!d'  1.txt   #删除1~2之外的所有行

sed  '$d'   1.txt      #删除最后一行

sed  '/123/d'   1.txt   #删除匹配123内容的行

sed  '/123/,$d'  1.txt  #删除从匹配123的行到最后一行

sed  '/123/,+1d'  1.txt   #删除匹配123的行及其后面一行

sed  '/^$/d'    1.txt    #删除空行

sed   '/123\|abc/!d'  1.txt    #删除不匹配123或abc的行，/123\|abc/ 表示匹配123或abc ，！表示取反

sed  '1,3{/123/d}'   1.txt     #删除1~3行中，匹配内容123的行，1,3表示匹配1~3行，{/123/d}表示删除匹配123的行
```

## 替换文件中内容
```shell
sed  's/123/hello/'   1.txt   #将文件中的123替换为hello，默认只替换每行第一个123

sed  's/123/hello/g'  1.txt #将文本中所有的123都替换为hello

sed 's/123/hello/2'   1.txt  #将每行中第二个匹配的123替换为hello

sed  -n 's/123/hello/gpw  2.txt'   1.txt    #将每行中所有匹配的123替换为hello，并将替换后的内容写入2.txt

sed  '/#/s/,.*//g'  1.txt   #匹配有#号的行，替换匹配行中逗号后的所有内容为空  (,.*)表示逗号后的所又内容

sed  's/..$//g'  1.txt  #替换每行中的最后两个字符为空，每个点代表一个字符，$表示匹配末尾  （..$）表示匹配最后两个字符

sed 's/^#.*//'  1.txt      #将1.txt文件中以#开头的行替换为空行，即注释的行  ( ^#)表示匹配以#开头，（.*）代表所有内容

sed 's/^#.*// ; /^$/d'  1.txt  #先替换1.txt文件中所有注释的空行为空行，然后删除空行，替换和删除操作中间用分号隔开

sed 's/^[0-9]/(&)/'   1.txt   #将每一行中行首的数字加上一个小括号   (^[0-9])表示行首是数字，&符号代表匹配的内容

sed  's/$/&'haha'/'  1.txt   # 在1.txt文件的每一行后面加上"haha"字段
```

## 打印文件中的行
```shell
sed  -n '3p'  1.txt   #打印文件中的第三行内容

sed  -n '2~2p'  1.txt   #从第二行开始，每隔两行打印一行，波浪号后面的2表示步长

sed -n '$p'  1.txt  #打印文件的最后一行

sed -n '1,3p'  1.txt  #打印1到3行

sed  -n '3,$p'  1.txt  #打印从第3行到最后一行的内容

sed  -n '/you/p'  1.txt   #逐行读取文件，打印匹配you的行

sed  -n '/bob/,3p'  1.txt  #逐行读取文件，打印从匹配bob的行到第3行的内容

sed  -n  '/you/,3p'  1.txt  #打印匹配you 的行到第3行，也打印后面所有匹配you 的行

sed  -n '1,/too/p'  1.txt    #打印第一行到匹配too的行

sed  -n  '3,/you/p'  1.txt   #只打印第三行到匹配you的行

sed  -n '/too/,$p'  1.txt  #打印从匹配too的行到最后一行的内容

sed  -n '/too/,+1p'  1.txt    #打印匹配too的行及其向后一行，如果有多行匹配too，则匹配的每一行都会向后多打印一行

sed  -n '/bob/,/too/p'  1.txt   #打印从匹配内容bob到匹配内容too的行
```
## 打印文件行号
```shell
sed  -n "$="   1.txt   #打印1.txt文件最后一行的行号（即文件有多少行，和wc -l 功能类似）

sed  -n '/error/='  1.txt     #打印匹配error的行的行号

sed  -n '/error/{=;p}'   1.txt    #打印匹配error的行的行号和内容（可用于查看日志中有error的行及其内容)
```

## 从文件中读取内容
```shell
sed  'r 2.txt'  1.txt  #将文件2.txt中的内容，读入1.txt中，会在1.txt中的每一行后都读入2.txt的内容

sed '3r 2.txt'  1.txt       #在1.txt的第3行之后插入文件2.txt的内容（可用于向文件中插入内容）

sed  '/245/r   2.txt'   1.txt    #在匹配245的行之后插入文件2.txt的内容，如果1.txt中有多行匹配245则在每一行之后都会插入

sed  '$r  2.txt'   1.txt     #在1.txt的最后一行插入2.txt的内容
```

## 向文件中写入内容
```shell
sed  -n  'w 2.txt'   1.txt   #将1.txt文件的内容写入2.txt文件，如果2.txt文件不存在则创建，如果2.txt存在则覆盖之前的内容

sed   -n '2w  2.txt'   1.txt   #将文件1.txt中的第2行内容写入到文件2.txt

sed  -n -e '1w  2.txt'  -e '$w 2.txt'   1.txt   #将1.txt的第1行和最后一行内容写入2.txt

sed  -n -e '1w  2.txt'  -e '$w  3.txt'  1.txt   #将1.txt的第1行和最后一行分别写入2.txt和3.txt

sed  -n  '/abc\|123/w  2.txt'    1.txt   #将1.txt中匹配abc或123的行的内容，写入到2.txt中

sed  -n '/666/,$w 2.txt'   1.txt   #将1.txt中从匹配666的行到最后一行的内容，写入到2.txt中

sed  -n  '/xyz/,+2w  2.txt'     1.txt     #将1.txt中从匹配xyz的行及其后2行的内容，写入到2.txt中
```
# `sed`在`shell`脚本中使用
## 实例1：替换文件中的内容
```shell
#!/bin/bash
if [ $# -ne 3 ];then                             #判断参数个数
  echo "Usage:  $0 old-part new-part filename"   #输出脚本用法
  exit
fi

sed -i "s#$1#$2#"  $3                    #将 旧内容进行替换，当$1和$2中包含"/"时，替换指令中的定界符需要更换为其他符号-#
```

## 实例2：删除文件中的空白行
```shell
#!/bin/bash

if [ ! -f $1 ];then         #判断参数是否为文件且存在

   echo "$0 is not a file"

   exit

fi

sed -i "/^$/d"   $1 #将空白行删除
```

## 实例3：格式化文本内容
```shell
#!/bin/bash
a='s/^  *>//      #定义一个变量a保存sed指令，'s/^ *>//'：表示匹配以0个或多空格开头紧跟一个'>'号的行，将匹配内容替换
s/\t*//                 #'s/\t*//'：表示匹配以0个或多个制表符开头的行，将匹配内容替换

s/^>//               #'s/^>//' ：表示匹配以'>'开头的行，将匹配内容替换

s/^ *//'               # 's/^ *//'：表示匹配以0个或多个空格开头的行，将匹配内容替换
#echo $a
sed "$a" $1        #对用户给定的文本文件进行格式化处理
```

## 实用脚本：批量更改当前目录中的文件后缀名：
### 示例1：
```shell
#!/bin/bash
if [ $# -ne 2 ];then               #判断用户的输入，如果参数个数不为2则打印脚本用法
  echo "Usage:$0 + old-file new-file"
  exit
fi
for i in *$1*                         #对包含用户给定参数的文件进行遍历
do
  if [ -f $i ];then
     iname=`basename $i`        #获取文件名
     newname=`echo $iname | sed -e "s/$1/$2/g"`         #对文件名进行替换并赋值给新的变量
     mv  $iname  $newname          #对文件进行重命名
   fi
done

exit 666
```

### 示例2：
```shell
#!/bin/bash
read -p "input the old file:" old        #提示用户输入要替换的文件后缀
read -p "input the new file:" new
[ -z $old ] || [ -z $new ] && echo "error" && exit      #判断用户是否有输入，如果没有输入就打印error并退出
for file in `ls *.$old`
do
  if [ -f $file ];then
     newfile=${file%$old}                        #对文件进行去尾
     mv $file ${newfile}$new                   #文件重命名
  fi

done
```

### 示例3：
```shell
#!/bin/bash

if [ $# -ne 2 ];then        #判断位置变量的个数是是否为2
   echo "Usage:$0  old-file  new-file"
   exit
fi
for file in `ls`                      #在当前目录中遍历文件
do
  if [[ $file =~ $1$ ]];then   #对用户给出的位置变量$1进行正则匹配，$1$表示匹配以变量$1的值为结尾的文件
     echo $file                      #将匹配项输出到屏幕进行确认
     new=${file%$1}             #对文件进行去尾处理，去掉文件后缀保留文件名，并将文件名赋给变量new                  
     mv $file ${new}$2          #将匹配文件重命名为：文件名+新的后缀名
  fi

done
```

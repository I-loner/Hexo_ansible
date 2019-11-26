---
title: awk操作
tags:
  - linux
categories:
  - linux
  - shell
top: 100
date: 2019-11-26 15:54:30
---

# `awk`语法
```
akw [选项] '指令' 操作文件
```
# 常用选项
* `-F` 指令分隔符,分隔符用`""`引起来
* `-v` `var=value`在`awk`程序开始前指定一个`val`值给变量`var`, 变量值用于`awk`程序的`BEGIN`块
* `-f awk_file` 后面跟一个保存了`awk`程序文件,代替命令行指定`awk`程序

## 实例1:命令行直接输入`awk`指令
```shell
awk '{print}' 1.txt     # 逐行读取文件1.txt内容并打印

awk '{print $0}' 1.txt  # 逐行读取文件内容,并打印该行,$0保存的是当前行内容

awk '{print "hello"}' 1.txt     # 逐行读取1.txt内容,每行结束打印一个hello, 每行都打

awk '{print $1}' 1.txt      # 默认空白分隔符, 打印每行中第一个分隔符前的内容

awk -F ":" '{print $1}' /etc/passwd     # 使用:分隔符,打印 /etc/passwd第一列内容
```

## 实例2:将`awk`指令写入文件,通过`-f`选项调用
`BEGIN`用于初始化`FS`变量(列分隔符) ,或者初始化调用全局变量

`END`用于执行最后的运算或者打印最终输出结果

`END`和`BEGIN`不是必须的

```shell
vim awkscript
BEGIN {
    FS=":"
}
{print $1}

awk -f awkscript /etc/passwd        # 通过调用awk文件
```

## 实例3: `awk`中使用正则匹配,正则必须放在`//`中
```shell
awk '/123/{print}' 1.txt    # 打印匹配123的每一行内容

awk -F ":" '/123/{print $2}' 1.txt      # 打印匹配123 每行第二列内容

awk -F ":" '$1 ~ /root/{print $2}'  /etc/passwd    # 打印第一列匹配root的每一行的第二列内容 ~ 表示匹配
```

## `awk`的表达式和块
`awk`提供多个比较操作符: `==, > < <= >= != ~匹配 !~不匹配`
```shell
awk 'BEGIN{ FS=":"} $1 == "root" {print $3}' /etc/passwd 打印第一列是root的行的第三列内容
```

## `awk`中条件语句
```shell
awk 'BEGIN {FS=":"} {if ($1 ~ "root") {print $2}}' /etc/passwd # 打印第一列是root的行的第三列内容

awk 'BEGIN {FS=":"} ($1 ~"linux" || $2 ~"Network") {print $3}' 1.txt    # 打印第一列是linux或者第二列是network的行的第三列内容

```

## `NF`统计行中有多少列, `$NF`当前行最后一列内容, `NR`行号
```shell
awk '/ock/{print NF}' 1.txt     # 统计匹配ock的行中有多少列

awk 'NF == 3 {print}' 1.txt     # 打印有三列的行

awk '{if (NR >3) {print $NF} }' 1.txt   # 打印行号大于3的行的最后一列内容

awk '{if (NR > 3) {print NR".\t"$0} }' 1.txt    # 打印行号大于3的行号以及内容
```
## 最终输出多少个空行
```
awk 'BEGIN { x=0 } /^$/{x = x + 1} END {print "find" "x" "blank lines"' 1.txt 最终输出多少个空行

# 输出结果 , BEGIN 初始化x变量, 处理过程 匹配空行 x+1 最终输出END语句
find 3 blank lines
```

# `awk`脚本示例
## 打印文本中每一列内容
```shell
#!/bin/bash
num=`wc 1.txt | awk '{print $2}'  # 统计多少列
for i in `seq 1 $num`           #根据文件列数循环
do
    awk -v a=$i '{print $a}' 1.txt  # 打印每一列内容, -v 参数指定变量保存外部变量的值,将外部变量传递给awk
done
```
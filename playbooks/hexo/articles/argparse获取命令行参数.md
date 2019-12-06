---
title: argparse获取命令行参数
tags:
  - python
categories:
  - python
  - package
top: 100
date: 2019-12-05 16:32:08
updated:
---
# 参数解析包`argparse`
* `import argparse`
* `parser = argparse.ArgumentParser(description="your script description")` : 创建一个解析对象, `description`　可以为空，描述脚本用途
* `parser.add_argument()` : 向解析对象增加关注的命令行参数和选项
* `args = parser.parse_args()` :　进行解析
* `args.arg`: 使用解析对象获取其参数

## 位置参数
**不需要带 - **
```python
...
parser.add_argument("e")    # 添加位置参数　e   必传
args = parser.parse_args()
print(args.e)
```

## 可选参数
* 短参数，　如 `-h`
* 指定长参数，　如`--help`
* 可以共存，或者一个
```python
...
parser.add_argument("-v", "--verbosity", help="添加输出 verbosity")
args = parser.parse_args()
if args.verbosity:
    print("打开 verbosity")
```

**可以通过定义是指定不需要参数**, `action="store_ture"` ,返回的是`True or False`**

## 指定类型 `type`
```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('x', type=int, help="输入数字")
args = parser.parse_args()
y = args.x
answer = y ** 3 + y + 1
print(answer)
```

## 可选值 `choices=[]`
```python
parser.add_argument("-v", "--verbosity", type=int, choices=[0, 1, 2],
                    help="increase output verbosity")
```

## 程序用法帮助 
```python
argparse.ArgumentParser(description="calculate X to the power of Y")
```

## 互斥参数
不能同时出现`-v` `-q`
```python
group.add_argument("-v", "--verbose", action="store_true")
group.add_argument("-q", "--quiet", action="store_true")
```

## 参数默认值　`default`
```python
parser.add_argument(
    "-v",
    "--verbosity",
    type=int,
    choices=[0, 1, 2],
    default=1,
    help="increase output verbosity")
```

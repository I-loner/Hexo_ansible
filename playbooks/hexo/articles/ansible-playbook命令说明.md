---
title: ansible-playbook命令说明
tags:
  - linux
categories:
  - linux
  - ansible
top: 100
date: 2019-12-09 14:40:00

---

## `ansible-playbook`命令说明
书写 `playbook`使用的是 `yaml`语法，执行`playbook`需要使用 `ansible-playbook` 命令

`ansible-playbook` 命令选项和 `ansible`命令大部分相同, 常用语法如下：

```bash
ansbile-playbook --help
Usage: ansible-playbook  playbook.yml [options]
Options:
    -i inventory 指定inventory(使用的hosts文件)
    -C --check   检查playbook是否Ok
    -e EXTRA_VARS,--extra-vars=EXTRA_VARS   # 设置额外的变量，格式为key/value。-e "key=KEY"，
                                            # 如果是⽂件⽅式传⼊变量，则-e "@param_file"
    --flush-cache                           # 清空收集到的fact信息缓存
    --force-handlers                        # 即使task执⾏失败，也强制执⾏handlers
    --list-tags                             # 列出所有可获取到的tags
    --list-tasks                            # 列出所有将要被执⾏的tasks
    -t TAGS,--tags=TAGS                     # 以tag的⽅式显式匹配要执⾏哪些tag中的任务
    --skip-tags=SKIP_TAGS                   # 以tag的⽅式忽略某些要执⾏的任务。被此处匹配的tag中的任务都不会执⾏
    --start-at-task=START_AT_TASK           # 从此task开始执⾏playbook
    --step                                  # one-step-at-a-time:在每⼀个任务执⾏前都进⾏交互式确认
    --syntax-check                          # 检查playbook语法
```
## 执行过程
1. 同步阻塞执行，所有主机执行完一个任务，才去继续下一个；
2. 执行前自动收集fact信息，即操作主机信息；
    * `TASK [Gathering Facts] `
    * `ok :[localhost]`
3. 从显示结果可以看出任务是否真的执行
    * ` TASK [TASK_NAME]`
    * `changed: [localhost]`
4. 最后显示所有运行结果：
    * `PLAY RECAP`
    * `localhost    : ok=1  changed=1   unreachable=0   failed=0`
5. 每个`play`都包含数个`TASK`，且有响应信息 `PLAY RECAP`

# **playbook 的内容**
## `hosts` 和 `remote_user`
`hosts` 定义执行任务的主机或者主机组；编写主机方式多种：

```bash
---
    - hosts: centos6,centos7    # 可以用“，”逗号分割
    - hosts: all 或 *           # 表示所有inventory的主机
    - hosts: host1:host2:group1 # 取并集，全部都要
    - hosts: group1:&group2     # 取交集，取两个组都有的主机
    - hosts: group1:!host1      # 排除，在group1排除掉host1
    ...
    通配符: web*.baidu.com
    数字范围: web[0-5].baidu.com
    字母范围: web[a-d].baidu.com
    正则表达: 以"~"开头，~web\d\.baidu\.com
    
# 或者在命令行使用 "-l" 选项限定
ansible centos -l host[1:5] -m ping   # 表示centos主机组中只有host1到host5才执行ping模块

```

`remote_user` 指定远程主机上执行任务的用户,实际上也是`ssh`连接的用户：
* 可以某个`task`上单独定义该`task`身份，**单独的优先于全局的**
* 也支持权限是方式
```bash
---
    - hosts: centos6, centos7
      remote_user: root
      tasks:
        - name: run a command
          shell: /bin/date
        - name: copy a file to /tmp
          copy: src=/etc/fstab dest=/tmp
          remote_user: myuser       # 单独使用user
   - hosts: centos8
     remote_user: yourname
     tasks:
        - name: run a command
          shell: /bin/date
          become: yes
          become_method: sudo  
          become_user: root         # 此项默认值为root， 可省
```

## `task list` 任务列表
1. 每个`play`包含一个`hosts`和一个`tasks`，`hosts`定义`inventory`中待控制主机，`tasks`定义任务列表，比如调用模块，顺序由上至下，一次执行一个；
2. `ansible-playbook -vvvv`信息，会发现临时任务文件是通过`sftp`上传到被控主机，(如果进行了筛选)但只有一部分被筛选主机才会`ssh`过去执行；
3. **当有一台执行失败，会被移除执行任务列表，就是说它一个出错后面，它这个被控主机任务不会继续；
4. 具有**幂等性**，多次执行不会影响那些成功执行的任务；还表现在**修正了playbook再次执行，不影响那些原本已经执行成功的**；

### 定义`task`细节
1. 可以为每个`task`加上`name`，也可以多个依赖一个`name`；
```bash
tasks:
    - name: do someting to initialize db        # 只是描述性语句，可以定义在任何地方
      file : path=/mydata/data state=directory owner=mysql group=mysql mode=0755
    - shell: /usr/bin/mysql_install_db --datadir=/mydata/data --user=mysql creates=/mydata/data/ibdata1
```
2. `playbook`中每调用一个模块都成为一个`action`，一般有三种传递参数的方式：

例如：定义一个确保服务是开启状态的`task`，
```bash
tasks:
    - name: be sure the sshd is running
      service: name=ssh state=started           # 方法一：  key=value,直接传递参数给模块
      
      service:                                  # 方法二：  key: value方式
        name: sshd      
        state: started          
        
      service:                                  # 使用关键字args, 定义key: value
      args:
        name: sshd
        state: started
```
3. 使用`include`命令可以引入其他`playbook`文件包含到此`playbook`

## `notify`和`handler`
被控主机的状态是否发生改变是能被捕捉的，即每个任务的`changed=true`或`changed=false`；

`ansible`捕捉到`changed=true`时，可以触发`notify`组件，`notify`是一个组件，并非模块；

**notify可以定义在action中，主要目的时调用handler**
```bash
tasks:
    - name: copy template file to remote host
      template: src=/etc/ansible/nginx.conf.j2  dest=/etc/nginx/nginx.conf
      notify:
        - restart nginx
        - test web page
      copy: src=nginx/index.html.j2 dest=/usr/share/nginx/html/index.html
      notify:                                           # notfiy是在执行完一个play中所有task后被触发的，在一个play中也只会被触发一次
        - restart nginx                                 # 比如这个重启，只会


handlers:
    - name: restart nginx                               # 名称需要和notify组件名称一致
      service: name=nginx state=restarted
    - name: test web page
      shell: curl -I http://192.168.100.10/index.html |grep 200 || /bin/false
```

这表示执行 `template`模块任务时，捕捉到`changed=true`,就会触发`notify`的`handler`任务。


`handler` 主要用于重启服务，或者系统重启


# `Playbook`中变量使用
## 命令行指定变量
执行 `playbook`时候通过参数 `-e` 传入变量，这时候**整个** `playbook`中都可以被调用，属于**全局变量**
```bash
[root@ansible PlayBook]# cat variables.yml 
---
- hosts: all
  remote_user: root

  tasks:
    - name: install pkg
      yum: name={{ pkg }}

#执行playbook 指定pkg
[root@ansible PlayBook]# ansible-playbook -e "pkg=httpd" variable.yml
```
## `hosts`文件中定义变量
在 `/etc/ansible/hosts` 文件中定义变量，可以针对**每个主机定义不同变量**,**也可以定义一个组变量**，直接在`playbook`中调用

**组中定义变量 优先级 < 单个主机优先级** 

```bash
 # 编辑hosts文件定义变量
[root@ansible PlayBook] # vim /etc/ansible/hosts
[apache]
192.168.1.36 webdir=/opt/test     # 定义单个主机的变量
192.168.1.33
[apache:vars]      # 定义整个组的统一变量
webdir=/web/test

[nginx]
192.168.1.3[1:2]
[nginx:vars]
webdir=/opt/web


# 编辑playbook文件
[root@ansible PlayBook] # cat variables.yml 
---
- hosts: all
  remote_user: root

  tasks:
    - name: create webdir
      file: name={{ webdir }} state=directory   # 引用变量


# 执行playbook
[root@ansible PlayBook]# ansible-playbook variables.yml

# 1.36 使用了webdir=/opt/test
# 1.33 使用了webdir=/web/test
```

## `playbook` 文件中定义变量
编写`playbook`时，直接可以在里面定义变量。**使用-e传入参数是，优先级-e最大**
```bash
# 编辑playbook
[root@ansible PlayBook] # cat variables.yml 
---
- hosts: all
  remote_user: root
  vars:                #定义变量
    pkg: nginx         #变量1
    dir: /tmp/test1    #变量2

  tasks:
    - name: install pkg
      yum: name={{ pkg }} state=installed    #引用变量
    - name: create new dir
      file: name={{ dir }} state=directory   #引用变量


# 执行playbook
[root@ansible PlayBook]# ansible-playbook variables.yml

# 如果执行时候又重新指定了变量的值，那么会以重新指定的为准
[root@ansible PlayBook]# ansible-playbook -e "dir=/tmp/test2" variables.yml
```
## 调用`setup`模块获取变量
`setup` 模块默认是获取主机信息，可以直接调用，[常用参数](https://buji595.github.io/2019/05/27/Ansible%20Ad-hoc%E5%B8%B8%E7%94%A8Module/#setup)

```bash
# 编辑playbook文件
[root@ansible PlayBook]# cat variables.yml 
---
- hosts: all
  remote_user: root

  tasks:
    - name: create file
      file: name={{ ansible_fqdn }}.log state=touch   # 主机名称 引用setup中的ansible_fqdn


# 执行playbook
[root@ansible PlayBook]# ansible-playbook variables.yml
```
## 独立的变量`YAML`文件中定义--`vars_files`
方便管理,将所有变量统一放在一个独立的变量`YAML`文件中,`playbook`文件直接引用
```bash
# 定义存放变量的文件
[root@ansible PlayBook]# cat var.yml 
var1: vsftpd
var2: httpd

# 编写playbook
[root@ansible PlayBook]# cat variables.yml 
---
- hosts: all
  remote_user: root
  vars_files:       # 引用变量文件
    - ./var.yml      #指定变量文件的path（这里可以是绝对路径，也可以是相对路径）

  tasks:
    - name: install package
      yum: name={{ var1 }}   #引用变量
    - name: create file
      file: name=/tmp/{{ var2 }}.log state=touch   #引用变量


# 执行playbook
[root@ansible PlayBook]# ansible-playbook  variables.yml
```
## 内置变量
1. `inventory_hostname:` 主机名
2. `groups:` 返回主机所在`inventory`文件中所有组和其内主机名
3. `group_names: `返回时主机所属主机组, 如果该主机在多个组,则返回多个组,不在组中,返回`ungrouped`
4. `hostvars`: 用于引用其他主机上收集的`facts`中数据,
5. `play_hosts` 代表是当前`play`所涉及`inventory`内所有主机名列表
6. `inventory_dir` 是所使用的`inventory`所在目录


# `playbook`标签使用 --`tags`
一个`playbook`文件中,执行时可以执行某个任务,那么**可以给每个任务集打标签**, 执行时候可以通过 `-t` 选择指定标签执行,也可以 `--skip-tags`选择标签以外
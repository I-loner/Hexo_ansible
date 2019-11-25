---
title: Ansible常用模块
tags:
  - Ansible
categories:
  - 运维
  - Ansible
top: 100
date: 2019-11-25 17:34:11
---
转载:[https://www.cnblogs.com/brianzhu/p/10174130.html](https://www.cnblogs.com/brianzhu/p/10174130.html)
更多模块：[https://www.cnblogs.com/brianzhu/p/10175477.html](https://www.cnblogs.com/brianzhu/p/10175477.html)

# `ansible`命令基础
```
ansible [host_name] 参数
```
* `host_name`就是你在`hosts`文件中定义的主机命名,表示执行的主机
* 常用参数
    * `-m module_name` 使用模块
    * `-a "args"` 传入模块中的参数
    * `-e "extra_vars"` 额外的变量，键值对
    * `-f number` 开启线程数量，默认`5`
    * `-o` 一行显示结果
    * `-B seconds` 异步执行，在`secons`后算失败
    * `-C` 检查是否连接

# 常用模块
## `ping`模块
```shell
ansible hosts -m ping
```

## `command`模块
**无法识别特殊符号**
```shell
root@ansible ~]# ansible-doc -s command
- name: Executes a command on a remote node
  command:
      argv:                  # 允许用户以列表和字符串的形式提供命令，不能同时使用，也不必须提供其中一种
      chdir:                 # 在执行命令之前，先cd到指定的目录下
      creates:               # 用于判断命令是否要执行，如果指定的文件存在(可以使用通配符)存在，则不执行
      free_form:             # 默认的选项，这里只是显示，实际上是没有的
      removes:               # 用于判断命令是否要执行，如果指定的文件存在(可以使用通配符)不存在，则不执行
      stdin:                 # 将命令的stdin直接设置为指定值
      warn:                  # 设置command的警告信息(在/etc/ansible/ansible.cfg中有配置项)
```

## `shell`模块
**shell模块实际上执行命令方式是**在远程使用`/bin/sh`执行
```shell
[root@ansible ~]# ansible-doc -s shell
- name: Execute commands in nodes.
  shell:
      chdir:                 # 在执行命令之前，先cd到指定的目录下
      creates:               # 用于判断命令是否要执行，如果指定的文件存在(可以使用通配符)存在，则不执行
      executable:            # 不再使⽤默认的/bin/sh解析并执⾏命令，⽽是使⽤此处指定的命令解析(例如使⽤expect解析expect脚本。必须为绝对路径)
      free_form:             # 默认的选项，这里只是显示，实际上是没有的
      removes:               # 用于判断命令是否要执行，如果指定的文件存在(可以使用通配符)不存在，则不执行
      stdin:                 # 将命令的stdin直接设置为指定值
      warn:                  # 设置command的警告信息(在/etc/ansible/ansible.cfg中有配置项)
```

## `script`模块
用于控制远程主机执行脚本，执行脚本前，**会将本地脚本传输到远程主机执行**，执行脚本采用远程主机`shell`环境
```shell
[root@ansible ~]# ansible-doc -s script
- name: Runs a local script on a remote node after transferring it
  script:
      chdir:                 # 在远程执⾏脚本前先切换到此⽬录下
      creates:               # 当此⽂件存在时，不执⾏脚本。可⽤于实现幂等性。
      decrypt:               # 此选项使用vault控制源文件的自动解密(对使用ansible-vault encrypt 文件名.yml 进行加密的文件解密)
      executable:            # 不再使⽤默认的/bin/sh解析并执⾏命令，⽽是使⽤此处指定的命令解析(例如使⽤expect解析expect脚本。必须为绝对路径)
      free_form:             # 本地待执⾏的脚本路径、选项、参数。之所以称为free_form，是因为它是脚本名+选项+参数。
      removes:               # 当此⽂件不存在时，不执⾏脚本。可⽤于实现幂等性。
```

## `copy`模块
复制本地文件或目录到远程主机上

```shell
[root@ansible ~]# ansible-doc -s copy
- name: Copies files to remote locations
  copy:
      backup:                # 拷贝的同时也创建⼀个包含时间戳信息的备份⽂件，默认为no,可以指定为backup=yes做文件备份
      content:               # 当用content代替src参数的时候，可以把content指定的内容直接写到一个文件
      decrypt:               # 此选项使用vault控制源文件的自动解密(对使用ansible-vault encrypt 文件名.yml 进行加密的文件解密)
      dest:                  # ⽬标路径，只能是绝对路径，如果拷贝的⽂件是⽬录，则⽬标路径必须也是⽬录
      directory_mode:        # 当对⽬录做递归拷贝时，设置了directory_mode将会使得只拷贝新建⽂件旧⽂件不会被拷贝。默认未设置.
      follow:                # 是否追踪到链接的源⽂件(follow=yes|on)
      force:                 # 设置为yes(默认)时，将覆盖远程同名⽂件。设置为no时，忽略同名⽂件的拷贝。
      group:                 # 指定文件拷贝到远程主机后的属组，但是远程主机上必须有对应的组，否则会报错
      local_follow:          # 是否遵循本地机器中的文件系统链接(local_follow=yes|on)
      mode:                  # 设置远程⽂件的权限。使⽤数值表⽰时不能省略第⼀位，如0644。也可以使⽤'u+rwx'或'u=rw,g=r,o=r'等⽅式设置
      owner:                 # 设置远程⽂件的所有者
      remote_src:            # 如果yes它会从目标机上搜索src文件(remote_src=yes|on)
      src:                   # 拷贝本地源⽂件到远程，可使⽤绝对路径或相对路径。如果路径是⽬录，且⽬录后加了斜杠"/"，则只会拷贝⽬录中的内容到远程，如果⽬录后不加斜杠，则拷贝⽬录本⾝和⽬录内的内容到远程
      unsafe_writes:         # 是否以不安全的方式进行，可能导致数据损坏(unsafe_writes=yes|on)
      validate:              # 复制前是否检验需要复制目的地的路径
```

## `fetch`模块
从被控远端上拉取文件
```shell
[root@ansible ~]# ansible-doc -s fetch
- name: Fetches a file from remote nodes
  fetch:
      dest:                  # 本地存储拉取⽂件的⽬录。例如dest=/data，src=/etc/fstab，远程主机名host.exp.com，则保存的路径为/data/host.exp.com/etc/fstab。
      fail_on_missing:       # 当设置为yes时，如果拉取的源⽂件不存在，则此任务失败。默认为no.
      flat:                  # 改变拉取后的路径存储⽅式。如果设置为yes，且当dest以"/"结尾时，将直接把源⽂件的basename存储在dest下。显然，应该考虑多个主机拉取时的⽂件覆盖情况。
      src:                   # 远程主机上的源⽂件。只能是⽂件，不⽀持⽬录。在未来的版本中可能会⽀持⽬录递归拉取.
      validate_checksum:     # fetch到⽂件后，检查其md5和源⽂件是否相同
```

## `file`模块
管理文件，目录的属性，也可以创建文件或者目录
```shell
[root@ansible ~]# ansible-doc -s file
- name: Sets attributes of files
  file:
      follow:                       # 是否遵循目的机器中的文件系统链接(可选值为:yes|on)
      force:                        # 当state=link的时候，可配合此参数强制创建链接文件，当force=yes时，表示强制创建链接文件
                                    # 不过强制创建链接文件分为三种情况。情况一：当要创建的链接文件指向的源文件并不存在时，使用此参数，可以先强制创建出链接文件。
                                    # 情况二：当要创建链接文件的目录中已经存在与链接文件同名的文件时，将force设置为yes，会将同名文件覆盖为链接文件，相当于删除同名文件，创建链接文件。
                                    # 情况三：当要创建链接文件的目录中已经存在与链接文件同名的文件，并且链接文件指向的源文件也不存在，这时会强制替换同名文件为链接文件
      group:                        # 设置远程⽂件的所属组
      mode:                         # 设置远程⽂件的权限。使⽤数值表⽰时不能省略第⼀位，如0644。也可以使⽤
      owner:                        # 设置远程⽂件的所有者
      path:                         # 必须的参数，用于指定要操作的文件或者目录
      recurse:                      # 当要操作的文件为目录，将recurse设置为yes，可以递归的修改目录中的文件属性
      src:                          # 当state设置为link或者hard时，表示我们想要创建一个软链接或者硬链接，所以，我们必须指明软链接或硬链链接的哪个文件，通过src参数即可指定链接源
      state:                        # 此参数非常灵活，其对应的值需要根据情况设定。比如，我们想要在远程主机上创建/testdir/a/b目录，那么则需要设置path=/testdir/a/b，
                                    # 但是，我们无法从”/testdir/a/b“这个路径看出b是一个文件还是一个目录，ansible也同样无法单单从一个字符串就知道你要创建文件还是目录，所以，我们需要通过state参数进行说明
                                    # state=directory:表示创建目录，如果path指定的不存在则被创建
                                    # state=touch:创建文件
                                    # state=link:创建软链接文件
                                    # state=hard:创建硬链接文件
                                    # state=absent:删除文件(删除时不用区分目标是文件、目录、还是链接)
      unsafe_writes:                # 是否以不安全的方式进行，可能导致数据损坏(unsafe_writes=yes|on)
```

## `rsync`模块
实现简单同步
```shell
[root@ansible ~]# ansible-doc -s synchronize
- name: A wrapper around rsync to make common tasks in your playbooks quick and easy.
  synchronize:
      archive:               # 等价于rsync的"-a"选项，即使⽤归档模式。它等价于rsync的"-rtopgDl"选项。值为yes/no.
      checksum:              # 是否对文件进行校验(在archive(归档)开启的时候checksum也是开启的).
      compress:              # 是否开启压缩，默认是开启的.
      copy_links:            # 同步的时候是否复制符号链接.
      delete:                # 删除源中没有但是目标存在的文件，使两边的数据内容一致，已推送为主需要设置参数recursive=yes结合使用.
      dest:                  # 目标文件及目录
      dest_port:             # 目标主机上的ssh的端口
      dirs:                  # 不使用递归的方式传送目录
      existing_only:         # receiver(接收端)没有的文件不同步，但仍会传输，只是临时文件重组后不重命名而已.
      group:                 # 保留所属组属性
      link_dest:             # 在rsync期间向硬链接添加目标
      links:                 # 拷贝链接文件自身
      mode:                  # 指定推(push)还是拉(pull)的传输模式
      owner:                 # 保留所有者属性
      partial:               # 等价于'--partial'选项，默认rsync在传输中断时会删除传输了一半的文件，指定该选项将保留这个部分不完整的文件，使得下次传输时可以直接从未完成的数据块开始传输.
      perms:                 # 保留权限属性.
      private_key:           # 指定基于ssh的rsync连接的私钥 (例如 `~/.ssh/id_rsa')
      recursive:             # 递归到目录中的文件.
      rsync_opts:            # 指定额外的rsync选项，使用数组的方式传递这些选项.
      rsync_path:            # 等价于'--rsync-path'选项，目的是启动远程rsync，例如可以指定[--rsync-path=rsync],甚至[--rsync-path=cd /tmp/c && rsync],当不指定rsync的路径时，默认是/usr/bin/rsync.
      rsync_timeout:         # 指定rsync在多久时间内没有数据传输就超时退出.
      set_remote_user:       # 主要用于/etc/ansible/hosts中定义或默认使用的用户与rsync使用的用户不同的情况.
      src:                   # (必选)指定待传输的源⽂件。可以是相对路径，也可以是绝对路径.
      times:                 # 保留mtime属性
      use_ssh_args:          # 使用ansible.cfg中配置的ssh_args
      verify_host:           # 对目标主机进行ssh的host key验证
```
### 实现本地推送目录下所有文件
```yml
synchronize:
       mode: push
       dest: "{{remote_hexo}}/source/_posts/{{name}}/"    
       src: "/home/jfn/桌面/myself/playbooks/hexo/articles/{{name}}/"   # 末尾/表示，目录下所有文件
```
### 实现远程拉取所有
```yml
synchronize:
        mode: pull
        dest: /home/jfn/桌面/myself/playbooks/hexo/articles/{{name}}/   # 要从远程拉下来存放的目录
        src: {{remote_hexo}}/source/_posts/{{name}}/        # 末尾为/，拉取目录下所有文件
```

## `cron`模块
设置定时任务
```shell
[root@ansible ~]# ansible-doc -s cron
- name: Manage cron.d and crontab entries
  cron:
      backup:                # (yes/on)如果设置了，则会在修改远程cron_file前备份这些文件
      cron_file:             # 自定义cron_file的文件名，使用相对路径则表示在/etc/cron.d/中，必选同时制定user选项
      minute:                # 分(0-59,*,/N),不写时默认为*
      hour:                  # 时(0-23,*,/N),不写时默认为*
      day:                   # 日(1-31,*,/N),不写时默认为*
      month:                 # 月(1-12,*,/N),不写时默认为*
      weekday:               # 周(0-6 for Sunday-Saturday,*),不写时默认为*
      disabled:              # 禁用crontab中的某个任务，要求state=present
      env:                   # (yes/on)设置一个环境变量，将添加在crontab的顶端，使用name=value定义变量名和值.
      job:                   # 需要执行的命令，如果设置了env，则表示环境变量的值，此时job="xxxx"等价于value="xxxx"
      name:                  # 描述crontab的字符串，但如果设置的是env,则name为环境变量的名称，要求state=absent，注意，若没有设置name，且state=present，则总会创建一条新的job条目，即使cron_file中已经存在同样的条目.
      reboot:                # 如果任务应该在重新启动时运行。不赞成使用此选项。用户应该使用special_time.
      special_time:          # 定时任务的别称，用于定义何时运行job条目.有效值有reboot/hourly/daily/weekly/monthly/yearly/annually
      state:                 # job或者env的状态是present(默认)还是absent，present用于创建，absent用于删除
      user:                  # 指定那个用户的crontab任务将要被修改，默认root.
```

## 更多请看连接啦＝－＝

MongoDB笔记
=====


## 安装

https://docs.mongodb.com/manual/tutorial/install-mongodb-on-linux/

官方提供yum和二进制包两种安装方式，建议使用二进制包手工安装。

* [自动安装脚本](shell/mongodb-3.4.10.sh)


## 配置

 MongoDB默认未启用登陆权限验证功能


## 命令 方法

连接mongodb
```shell
/usr/local/mongodb/bin/mongo
```

查看所有库
```shell
> show dbs
admin  0.000GB
local  0.000GB
```

查看当前库
```shell
> db
admin
```

查看所有表
```shell
> show collections
```

切换数据库
```shell
> use admin
switched to db admin
> show collections
system.version
```

查看所有内置角色
```shell
> show roles
{
    "role" : "__system",
    "db" : "admin",
    "isBuiltin" : true,
    "roles" : [ ],
    "inheritedRoles" : [ ]
}
{
    "role" : "backup",
    "db" : "admin",
    "isBuiltin" : true,
    "roles" : [ ],
    "inheritedRoles" : [ ]
}
{
    "role" : "dbAdmin",
    "db" : "admin",
    "isBuiltin" : true,
    "roles" : [ ],
    "inheritedRoles" : [ ]
}
{
    "role" : "dbAdminAnyDatabase",
    "db" : "admin",
    "isBuiltin" : true,
    "roles" : [ ],
    "inheritedRoles" : [ ]
}
{
    "role" : "dbOwner",
    "db" : "admin",
    "isBuiltin" : true,
    "roles" : [ ],
    "inheritedRoles" : [ ]
}
...
```

查看所有用户
```shell
> show users #空
```

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
# 本地MongoDB实例 默认端口 27017
/usr/local/mongodb/bin/mongo

# 本地MongoDB实例 非默认端口
mongo --port 28015

# 远程MongoDB实例 使用认证
mongo --username alice --password abc123 --host mongodb0.tutorials.com --port 28015 dbname
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
> show users
```

新建用户
```shell
> db.createUser( { user: "dba",
                 pwd: "duliang",
                 customData: { employeeId: 12345 },
                 roles: [ { role: "dbAdminAnyDatabase", db: "admin" },
                          { role: "userAdminAnyDatabase", db: "admin" },
                          "dbOwner"]} #这里没跟db:是指当前use的数据库的角色
)
Successfully added user: {
    "user" : "dba",
    "customData" : {
        "employeeId" : 12345
    },
    "roles" : [
        {
            "role" : "dbAdminAnyDatabase",
            "db" : "admin"
        },
        {
            "role" : "userAdminAnyDatabase",
            "db" : "admin"
        },
        "dbOwner"
    ]
}

> show users
{
    "_id" : "admin.dba",
    "user" : "dba",
    "db" : "admin",
    "customData" : {
        "employeeId" : 12345
    },
    "roles" : [
        {
            "role" : "dbAdminAnyDatabase",
            "db" : "admin"
        },
        {
            "role" : "userAdminAnyDatabase",
            "db" : "admin"
        },
        {
            "role" : "dbOwner",
            "db" : "admin"
        }
    ]
}

# 生成了users表
> show collections;
system.users
system.version
```

修改用户
```shell
db.updateUser( "dba",
               {
                 pwd: "dulaing",
                 customData: { ID: 1 },
                 roles: [ { role: "dbAdminAnyDatabase", db: "admin" },
                          { role: "userAdminAnyDatabase", db: "admin" },
                          "dbOwner"]
               }
             )
```

修改密码
```shell
db.changeUserPassword("dba", "duliang")
```

创建数据库(也是用use 不存在会自动新建)
```shell
> use test
switched to db test

# 有数据库才能创建
> show dbs
admin  0.000GB
local  0.000GB
```

自动创建表(集合)和插入数据
```shell
> db.tbl.insert({title: 'MongoDB',
     description: 'MongoDB is a database'
})
WriteResult({ "nInserted" : 1 })

# 有数据库自动创建
> show dbs
admin  0.000GB
local  0.000GB
test   0.000GB

> show collections
tbl
```


启开登陆权限验证
```shell
mongod --dbpath $DataDir --rest --auth
```

权限验证
```shell
# https://docs.mongodb.com/tutorials/enable-authentication/

# [ 在连接期间进行身份验证 ]
mongo --port 27017 -u "myTester" -p "xyz123" --authenticationDatabase "test"

# [ 连接后进行身份验证 ]
mongo --port 27017
> use test
> db.auth("myTester", "xyz123" )
```
```shell
/usr/local/mongodb/bin/mongo
MongoDB shell version v3.4.10
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.4.10
> db
test

# 无权限
> show dbs
2017-11-10T16:33:10.692+0800 E QUERY    [thread1] Error: listDatabases failed:{
    "ok" : 0,
    "errmsg" : "not authorized on admin to execute command { listDatabases: 1.0 }",
    "code" : 13,
    "codeName" : "Unauthorized"
} :
_getErrorWithCode@src/mongo/shell/utils.js:25:13
Mongo.prototype.getDBs@src/mongo/shell/mongo.js:62:1
shellHelper.show@src/mongo/shell/utils.js:781:19
shellHelper@src/mongo/shell/utils.js:671:15
@(shellhelp2):1:1

# 权限验证 无dba@test用户, 因为dba是在admin库中建立的
> db.auth("dba","duliang")
Error: Authentication failed. #mongod端log: UserNotFound: Could not find user dba@test
0
> use admin
switched to db admin
> db.auth("dba","duliang")
1

# admin库验证Ok 再切换test库(dba用户拥有dbAdminAnyDatabase角色权限)
> use test
switched to db test
> show dbs
admin  0.000GB
local  0.000GB
test   0.000GB
> show collections
tbl
# 但是插入不了数据 加个readWriteAnyDatabase

> db.updateUser( "dba",
               {
                 pwd: "duliang",
                  customData: { ID: 1 },
                  roles: [ { role: "dbAdminAnyDatabase", db: "admin" },
                           { role: "userAdminAnyDatabase", db: "admin" },
                           "dbOwner", "readWriteAnyDatabase"]
                }
             )

> db.tbl.insert({title: 'mysql',
     description: 'MySQL'
 })

> db.tbl.find()
{ "_id" : ObjectId("5a055363cd07997992a0c1ef"), "title" : "MongoDB", "description" : "MongoDB is a database" }
{ "_id" : ObjectId("5a056c0b05830e850b2a6048"), "title" : "mysql", "description" : "MySQL" }
```

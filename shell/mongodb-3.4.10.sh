# Manual Installation (手动安装)

#!/bin/bash
# ver: mongodb-linux-x86_64-rhel70
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-linux/
# curl -O 使用URL中默认的文件名保存文件到本地
#      -C 断点续传
# cp -n 不要覆盖已存在的文件
# ${FileName%.*}去文件扩展名; echo ${FileName##*.}取扩展名不含.

cat /etc/redhat-release
#CentOS Linux release 7.4.1708 (Core)

FileName=mongodb-linux-x86_64-rhel70-3.4.10.tgz
InstallPath=/usr/local/mongodb
DataDir=/data/mongodb #数据目录

mkdir -p $DataDir

cd /usr/local/src
curl -O https://fastdl.mongodb.org/linux/$FileName
tar -zxvf $FileName
cp -R -n ${FileName%.*}/ $InstallPath
export PATH=$InstallPath/bin:$PATH

# 默认配置文件 https://docs.mongodb.com/manual/reference/configuration-options/
cat >> /etc/mongod.conf <<EOF
net:
   bindIp: 127.0.0.1,192.168.0.60
   port: 27017
EOF

#不指定--dbpath的话默认/data/db
mongod --dbpath $DataDir --rest


# curl http://192.168.1.176:28017/



#========================================================================================
# MongoDB默认未启用登陆权限验证功能 https://docs.mongodb.com/manual/reference/method/db.createUser/
/usr/local/mongodb/bin/mongo
# 查看所有库
#> show dbs
#admin  0.000GB
#local  0.000GB

# 查看当前库
# > db
#admin


# 查看所有表
#> show collections

# 切换数据库
#> use admin
#switched to db admin
#> show collections
#system.version

# 查看所有内置角色
# > show users #空
# > show roles
# {
#     "role" : "__system",
#     "db" : "admin",
#     "isBuiltin" : true,
#     "roles" : [ ],
#     "inheritedRoles" : [ ]
# }
# {
#     "role" : "backup",
#     "db" : "admin",
#     "isBuiltin" : true,
#     "roles" : [ ],
#     "inheritedRoles" : [ ]
# }
# {
#     "role" : "dbAdmin",
#     "db" : "admin",
#     "isBuiltin" : true,
#     "roles" : [ ],
#     "inheritedRoles" : [ ]
# }
# {
#     "role" : "dbAdminAnyDatabase",
#     "db" : "admin",
#     "isBuiltin" : true,
#     "roles" : [ ],
#     "inheritedRoles" : [ ]
# }
# {
#     "role" : "dbOwner",
#     "db" : "admin",
#     "isBuiltin" : true,
#     "roles" : [ ],
#     "inheritedRoles" : [ ]
# }
# ...

# 新建用户
# > db.createUser( { user: "dba",
#                  pwd: "dulaing",
#                  customData: { employeeId: 12345 },
#                  roles: [ { role: "dbAdminAnyDatabase", db: "admin" },
#                           { role: "userAdminAnyDatabase", db: "admin" },
#                           "dbOwner"]} #这里没跟db:是指当前use的数据库的角色
# )
# Successfully added user: {
#     "user" : "dba",
#     "customData" : {
#         "employeeId" : 12345
#     },
#     "roles" : [
#         {
#             "role" : "dbAdminAnyDatabase",
#             "db" : "admin"
#         },
#         {
#             "role" : "userAdminAnyDatabase",
#             "db" : "admin"
#         },
#         "dbOwner"
#     ]
# }

# 查看所有用户
# > show users;
# {
#     "_id" : "admin.dba",
#     "user" : "dba",
#     "db" : "admin",
#     "customData" : {
#         "employeeId" : 12345
#     },
#     "roles" : [
#         {
#             "role" : "dbAdminAnyDatabase",
#             "db" : "admin"
#         },
#         {
#             "role" : "userAdminAnyDatabase",
#             "db" : "admin"
#         },
#         {
#             "role" : "dbOwner",
#             "db" : "admin"
#         }
#     ]
# }

# > show collections;
# system.users
# system.version

# 修改用户
# db.updateUser( "dba",
#                {
#                  pwd: "dulaing",
#                  customData: { ID: 1 },
#                  roles: [ { role: "dbAdminAnyDatabase", db: "admin" },
#                           { role: "userAdminAnyDatabase", db: "admin" },
#                           "dbOwner"]
#                }
#              )

# 修改密码
# db.changeUserPassword("dba", "duliang")


# > show dbs;
# admin  0.000GB
# local  0.000GB

# 创建数据库(也是用use 不存在会自动新建)
# > use test
# switched to db test
# > show dbs
# admin  0.000GB
# local  0.000GB

# 自动创建表(集合)和插入数据
# > db.tbl.insert({title: 'MongoDB',
# ...     description: 'MongoDB is a database'
# ... })
# WriteResult({ "nInserted" : 1 })
# > show dbs
# admin  0.000GB
# local  0.000GB
# test   0.000GB
# > show collections
# tbl
# >

#启开登陆权限验证
mongod --dbpath $DataDir --rest --auth

# /usr/local/mongodb/bin/mongo
# MongoDB shell version v3.4.10
# connecting to: mongodb://127.0.0.1:27017
# MongoDB server version: 3.4.10
# > db
# test
# 无权限
# > show dbs
# 2017-11-10T16:33:10.692+0800 E QUERY    [thread1] Error: listDatabases failed:{
#     "ok" : 0,
#     "errmsg" : "not authorized on admin to execute command { listDatabases: 1.0 }",
#     "code" : 13,
#     "codeName" : "Unauthorized"
# } :
# _getErrorWithCode@src/mongo/shell/utils.js:25:13
# Mongo.prototype.getDBs@src/mongo/shell/mongo.js:62:1
# shellHelper.show@src/mongo/shell/utils.js:781:19
# shellHelper@src/mongo/shell/utils.js:671:15
# @(shellhelp2):1:1
# 权限验证 无dba@test用户, 因为dba是在admin库中建立的
# > db.auth("dba","duliang")
# Error: Authentication failed. #mongod端log: UserNotFound: Could not find user dba@test
# 0
# > use admin
# switched to db admin
# > db.auth("dba","duliang")
# 1
# admin库验证Ok 再切换test库(dba用户拥有dbAdminAnyDatabase角色权限)
# > use test
# switched to db test
# > show dbs
# admin  0.000GB
# local  0.000GB
# test   0.000GB
# > show collections
# tbl
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

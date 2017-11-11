#!/bin/bash
# ver: mongodb-linux-x86_64-rhel70
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
# net.bindIp指mongodb服务器网卡的IP 非访客的IP
# 不指定--dbpath的话默认/data/db
cat >> /etc/mongod.conf <<EOF
net:
  bindIp: 0.0.0.0 #0.0.0.0表示监听本机的所有IP网卡=127.0.0.1,42.121.6.138
  port: 27017

security:
  authorization: enabled

storage:
  dbPath: /data/mongodb
EOF


/$InstallPath/bin/mongod -f /etc/mongod.conf --rest #实例加载的配置参数可通过日志中options一行查看

# web rest地址访问(如果开启了--auth认证, rest web使用DB账号密码登陆会提示not allowed, 官方对rest登陆验证支持不好, 不建议使用)
# curl http://192.168.1.176:28017/

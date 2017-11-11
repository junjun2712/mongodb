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
cat >> /etc/mongod.conf <<EOF
net:
   bindIp: 127.0.0.1,192.168.0.60
   port: 27017
EOF

#不指定--dbpath的话默认/data/db
/$InstallPath/bin/mongod --dbpath $DataDir --rest

# web rest地址访问
# curl http://192.168.1.176:28017/

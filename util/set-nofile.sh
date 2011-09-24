#! /bin/bash
ROOT='..'
NOFILE=65535
NODE_LIST=`cat $ROOT/node.list`
for node in $NODE_LIST
do
  ssh root@$node "echo 'ulimit -SHn $NOFILE' >> /etc/profile"
done

#! /bin/bash
ROOT='../..'
NODE_LIST=`cat $ROOT/node.list`

i=1
for node in $NODE_LIST
do
  ssh root@$node "cat /proc/meminfo" > node$i.meminfo &
  ssh root@$node "cat /proc/cpuinfo" > node$i.cpuinfo &
  ((++i))
done
wait

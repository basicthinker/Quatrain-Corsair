#! /bin/bash
LOG_DIR='../log'
NODE_LIST=`cat ../node.list`

i=1
for node in $NODE_LIST
do
  scp root@$node:~/log-* $LOG_DIR &
  ssh root@$node "cat ~/server.output | awk '/Group.*/'" > $LOG_DIR/server.output$i &
  ((++i))
done
wait

if [ $# == 0 ]; then
  exit 0
fi

echo ">>> Do clean."
for node in $NODE_LIST
do
  if [ $1 == 'rm' ]; then
    ssh root@$node "rm ~/log-*" &
  elif [ $1 == 'mv' ]; then
    ssh root@$node "if [ ! -d ~/bak-log ]; then mkdir ~/bak-log; fi; mv ~/log-* ~/bak-log/" &
  fi
done
wait
echo "<<< Finish."

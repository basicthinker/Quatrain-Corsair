#! /bin/bash
LOG_DIR='log'
NODE_LIST=`cat node.list`
PORT=3500
PING_CNT=50
LIMIT=50
NOFILE=65535

EVA_LOG=eva-`date +%s`.log

if [ ! -d $LOG_DIR ] ; then
  mkdir -p $LOG_DIR
fi

if [ "$1" == "-p" ]; then
  echo ">>> Begin of ping stage"
  i=1
  for node in $NODE_LIST
  do
    echo "Starting ping on node-$i..."
    ssh root@$node 'for node in '$NODE_LIST'; do ping -c 3 $node > /dev/null; ping -q -c '$PING_CNT' $node; done' > $LOG_DIR/ping-node$i-`date +%s`.log &
    ((++i))
  done
  wait
  echo "<<< End of ping stage"
fi

echo ">>> Begin of evaluation"
i=1
for node in $NODE_LIST
do
  echo "Starting evaluation client on node-$i..."
  ssh root@$node "ulimit -SHn $NOFILE; \
    nohup java -jar ~/corsair-client.jar $node $PORT $LIMIT 10000 200" > $LOG_DIR/node$i.log &
  ((++i))
done
wait

echo "<<< End of evaluation"

echo -e "# NodeNum\tNormalTime\tMrTime" > $EVA_LOG
i=1
for node in $NODE_LIST
do
  value=`cat $LOG_DIR/node$i.log`
  echo -e "$i\t$value" >> $EVA_LOG;
  rm $LOG_DIR/node$i.log
  ((++i))
done

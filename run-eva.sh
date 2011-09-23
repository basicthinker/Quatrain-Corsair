#! /bin/bash
NODE_LIST=`cat node.list`
PORT=3500
PING_CNT=5
LIMIT=5

EVA_LOG=eva-`date +%s`.log

echo ">>> Begin of ping stage"
i=1
for node in $NODE_LIST
do
  echo "Starting ping on node-$i..."
  ssh root@$node 'for node in '$NODE_LIST'; do ping -c 3 $node > /dev/null; ping -q -c '$PING_CNT' $node; done' > ping-node$i-`date +%s`.log &
  ((++i))
done
wait
echo "<<< End of ping stage"

echo ">>> Begin of evaluation"
i=1
for node in $NODE_LIST
do
  echo "Starting evaluation client on node-$i..."
  ssh root@$node "nohup java -jar ~/corsair-client.jar $node $PORT $LIMIT 30000" > node$i.log &
  ((++i))
done
wait
echo "<<< End of evaluation"

echo -e "# NodeNum\tNormalTime\tMrTime" > $EVA_LOG
i=1
for node in $NODE_LIST
do
  value=`cat "node$i.log"`
  echo -e "$i\t$value" >> $EVA_LOG;
  rm node$i.log
  ((++i))
done

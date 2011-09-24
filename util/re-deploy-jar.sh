#! /bin/bash
DB_USER=root
DB_PASSWD=tsinghua
PORT=3500
ROOT='..'

NODE_LIST=`cat $ROOT/node.list`
SERVER_LIST=(`cat $ROOT/server-ip.list`)

echo ">>> Copying files..."
for node in $NODE_LIST
do
  scp $ROOT/corsair-client.jar root@$node:~/ &
  scp $ROOT/corsair-server.jar root@$node:~/ &
done
wait
echo "<<< End copying..."

i=1
for node in $NODE_LIST
do
  ssh root@$node "ps aux | grep 'corsair' | grep -v 'grep' | awk '{print \$2}' | xargs kill -9 ;\
    nohup java -jar ~/corsair-server.jar ${SERVER_LIST[$((i-1))]} $PORT 100 corsair_lmr_$i $DB_USER $DB_PASSWD 20000 > ~/server.output 2>&1 & \
    sleep 1 ; cat ~/server.output"
  ((++i))
done


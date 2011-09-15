#! /bin/bash
cd database
source header.sh
cd ..

DB_FILE='database/corsair-db-all.sql'
PORT=3500

if [ -f $DB_FILE ]; then
  echo ">>> Using existing $DB_FILE"
else
  echo '<<< Dumping databases...'
  mysqldump -u $DB_USER -p$DB_PASSWD --all-databases --add-drop-database > $DB_FILE
fi

NODE_LIST=`cat node.list`

if [ ! -f ~/.ssh/id_dsa.pub ]; then
  ssh-keygen
fi
echo ">>> Setting up ssh without password..."
for node in $NODE_LIST
do
  ssh root@$node 'if [ ! -d ~/.ssh ]; then ssh-keygen; fi'
  scp ~/.ssh/id_dsa.pub root@$node:~/rid_dsa.pub
  ssh root@$node 'cat ~/rid_dsa.pub >> ~/.ssh/authorized_keys;
    rm ~/rid_dsa.pub'
done
echo "<<< Setting finished!"

echo ">>> Begin JDK isntallation..."
for node in $NODE_LIST
do
  ssh root@$node "apt-get install -y default-jdk" &
done
wait
echo "<<< JDK isntallation finished!"

echo ">>> Begin MySQL installation."
for node in $NODE_LIST
do
  ssh root@$node "apt-get install -y mysql-server" &
done
wait
echo "<<< MySQL installation finished!"

echo ">>> Begin copying DB files..."
for node in $NODE_LIST
do
  scp $DB_FILE root@$node:~/ &
done
wait
echo "<<< Copying finished!"

echo ">>> Begin DB restore..."
for node in $NODE_LIST
do
  ssh root@$node "mysqladmin -u $DB_USER flush-privileges password $DB_PASSWD" 
  ssh root@$node "mysql -u $DB_USER -p$DB_PASSWD < ~/corsair-db-all.sql" &
done
wait
echo "<<< DB restore finished!"

echo ">>> Begin starting services..."
i=1
for node in $NODE_LIST
do
  scp corsair-server.jar root@$node:~/
  ssh root@$node "nohup java -jar ~/corsair-server.jar $node $PORT 30 corsair_lmr_$i $DB_USER $DB_PASSWD 30000 > /dev/null &"
  ssh root@$node "cat ~/server.output"
  ((++i))
done
echo "<<< Services started!"

echo ">>> Begin starting clients..."
for node in $NODE_LIST
do
  scp corsair-client.jar root@$node:~/
  ssh root@$node "nohup java -jar ~/corsair-client.jar $node $PORT 30000 > /dev/null &"
done
echo "<<< All done!"

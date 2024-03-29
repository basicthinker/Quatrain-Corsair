#! /bin/bash
cd database
source header.sh
cd ..

DB_FILE='database/corsair-db-all.sql'
PORT=3500
NODE_LIST=`cat node.list`
SERVER_LIST=(`cat server-ip.list`)
NOFILE=65535

if [ -f $DB_FILE ]; then
  echo ">>> Using existing $DB_FILE"
else
  echo '<<< Dumping databases...'
  # reset IPs in case that nodes are not ready when DB is built
  echo 'USE corsair_smr;' > tmp.sql
  i=1
  for node in $NODE_LIST
  do
    echo "UPDATE smr_local_mgr SET ip_address='$node' WHERE id='$((10000+i))';" >> tmp.sql
    ((++i))
  done
  mysql -u $DB_USER -p$DB_PASSWD < tmp.sql
  rm tmp.sql

  DB_NAMES="corsair_smr"
  i=1
  for node in $NODE_LIST
  do
    DB_NAMES=$DB_NAMES" corsair_lmr_$i"
    ((++i))
  done
  mysqldump -u $DB_USER -p$DB_PASSWD --databases $DB_NAMES --add-drop-database --routines > $DB_FILE
fi

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

read -p "Press any key to continue..."

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

read -p "Press any key to continue..."

echo ">>> Begin DB restore..."
for node in $NODE_LIST
do
  ssh root@$node "mysqladmin -u $DB_USER password '$DB_PASSWD'"
  ssh root@$node "mysql -u $DB_USER -p$DB_PASSWD < ~/corsair-db-all.sql" &
done
wait
echo "<<< DB restore finished!"

read -p "Press any key to continue..."

echo ">>> Begin starting services..."

for node in $NODE_LIST
do
  scp bin/corsair-server.jar root@$node:~/ &
  scp bin/corsair-client.jar root@$node:~/ &
  scp bin/mysql-connector-java-5.1.17-bin.jar root@$node:/usr/lib/jvm/default-java/jre/lib/ext/ &
done
wait

i=1
for node in $NODE_LIST
do
  ssh root@$node "ps aux | grep 'corsair' | grep -v 'grep' | awk '{print \$2}' | xargs kill -9 ; sleep 1; \
    ulimit -SHn $NOFILE; \
    nohup java -jar ~/corsair-server.jar ${SERVER_LIST[$((i-1))]} $PORT 100 corsair_lmr_$i $DB_USER $DB_PASSWD 8000 > ~/server.output 2>&1 & \
    sleep 1 ; cat ~/server.output ; ulimit -n;" &
  ((++i))
done
wait
echo "<<< Services started!"

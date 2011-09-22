#! /bin/bash
DB_USER=root
DB_PASSWD=tsinghua
NODE_LIST=`cat node.list`

  # reset IPs in case that nodes are not ready when DB is built
  echo 'USE corsair_smr;' > tmp.sql
  i=1
  for node in $NODE_LIST
  do
    echo "UPDATE smr_local_mgr SET ip_address='$node' WHERE id='$((10000+i))';" >> tmp.sql
    ((++i))
  done

  for node in $NODE_LIST
  do
    scp tmp.sql root@$node:~/ &
  done
  wait

  for node in $NODE_LIST
  do
    ssh root@$node "mysql -u $DB_USER -p$DB_PASSWD < ~/tmp.sql; rm ~/tmp.sql" &
  done
  wait

  echo ">>> Begin checking..."
  echo "select ip_address from corsair_smr.smr_local_mgr;" > tmp.sql

  for node in $NODE_LIST
  do
    scp tmp.sql root@$node:~/ &
  done
  wait

  i=1
  for node in $NODE_LIST
  do
    echo ">>> Node $i" > check.list$i
    ssh root@$node "mysql -u $DB_USER -p$DB_PASSWD < ~/tmp.sql; rm ~/tmp.sql" >> check.list$i &
    ((++i))
  done
  wait

  date > check.list
  i=1
  for node in $NODE_LIST
  do
    cat check.list$i >> check.list
    rm check.list$i
    ((++i))
  done
  echo "<<< End checking. Please refer to the file check.list."

  rm tmp.sql

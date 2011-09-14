#! /bin/bash

source header.sh

mysqldump -u $DB_USER -p$DB_PASSWD --all-databases --add-drop-database > corsair-db-all.sql

NODE_LIST=`cat node.list`
for node in $NODE_LIST
do
  # set up ssh without password
  ssh root@$node 'ssh-keygen'
  scp ~/.ssh/id_rsa.pub root@$node:~/.ssh/rid_rsa.pub
  ssh root@$node 'cat ~/.ssh/rid_rsa.pub >> ~/.ssh/authorized_keys;
    rm ~/.ssh/rid_rsa.pub'

  # install database
  ssh root@$node 'apt-get install -y mysql-server'
  scp corsair-db-all.sql root@$node:~/
  ssh root@$node "mysql -u $DB_USER -p$DB_PASSWD < ~/corsair-db-all.sql"

  # grand remote access
  echo "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWD';FLUSH PRIVILEGES;" > temp.sql
  scp temp.sql root@$node:~/
  rm temp.sql
  ssh root@$node "mysql -u root -ptsinghua < ~/temp.sql"
  ssh root@$node "rm ~/temp.sql"
done

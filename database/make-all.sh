#! /bin/bash

source ./header.sh

echo "Creating database..." > check.list
mysql $V_OPTION -u $DB_USER -p$DB_PASSWD < corsair_smr_db.sql 

for ((i=1; i<=$LOCAL_CNT; i++))
do
  echo "DROP DATABASE IF EXISTS corsair_lmr_$i;" > temp.sql
  echo "CREATE DATABASE corsair_lmr_$i;" >> temp.sql
  echo "USE corsair_lmr_$i;" >> temp.sql
  cat corsair_lmr_db_core.sql >> temp.sql
  mysql $V_OPTION -u $DB_USER -p$DB_PASSWD < temp.sql

  cat corsair_lmr_data.sql > temp.sql
  echo "CALL sp_fill_lmr_db_core($LMR_USR_CNT, $LMR_COMMU_CNT, 0, $LMR_USR_COMMU, $LMR_GRP_CNT, $LMR_COMMU_GRP);" >> temp.sql
  mysql $V_OPTION -u $DB_USER -p$DB_PASSWD -D corsair_lmr_$i < temp.sql

  echo "Prepare for filling database No. $i..." >> check.list
  mysql $V_OPTION -u $DB_USER -p$DB_PASSWD -D corsair_lmr_$i < corsair_lmr_sp.sql
  echo "Finish filling database No. $i." >> check.list
done

./make_corsair_smr_data_sync.sh
mysql $V_OPTION -u $DB_USER -p$DB_PASSWD < corsair_smr_data_sync.sql
echo "Prepare sync smr..." >> check.list
mysql $V_OPTION -u $DB_USER -p$DB_PASSWD < corsair_smr_sp.sql
echo "Finish sync." >> check.list

rm temp.sql

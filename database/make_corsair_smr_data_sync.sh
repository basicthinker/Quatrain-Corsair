#! /bin/bash

source ./header.sh

# Produce the file corsair_smr_data_sync.sql

echo "USE corsair_smr;" > corsair_smr_data_sync.sql
echo "SET character_set_client = GBK;" >> corsair_smr_data_sync.sql
echo "DELIMITER //" >> corsair_smr_data_sync.sql
echo >> corsair_smr_data_sync.sql

echo "DROP PROCEDURE IF EXISTS insert_smr_local_mgr;" >> corsair_smr_data_sync.sql
echo "CREATE PROCEDURE insert_smr_local_mgr ()" >> corsair_smr_data_sync.sql
echo "BEGIN" >> corsair_smr_data_sync.sql
for ((i=0; i<$LOCAL_CNT; i++))
do
  echo "  INSERT INTO smr_local_mgr VALUES (" >> corsair_smr_data_sync.sql
  echo "    $((i+10000)), 'University$i', 'No. $i'" >> corsair_smr_data_sync.sql
  echo "  );" >> corsair_smr_data_sync.sql
done
echo "END;" >> corsair_smr_data_sync.sql
echo >> corsair_smr_data_sync.sql

echo "DROP PROCEDURE IF EXISTS insert_smr_overall_user;" >> corsair_smr_data_sync.sql
echo "CREATE PROCEDURE insert_smr_overall_user()" >> corsair_smr_data_sync.sql
echo "BEGIN" >> corsair_smr_data_sync.sql
for ((i=0; i<$LOCAL_CNT; i++))
do
  echo "  INSERT INTO smr_overall_user SELECT $((i+10000)), id, name, username, password, email, phone, sync_time" >> corsair_smr_data_sync.sql
  echo "  FROM corsair_lmr_$i.jos_users JOIN corsair_lmr_$i.lmr_user_patch ON lmr_user_patch.user_id = jos_users.id;" >> corsair_smr_data_sync.sql
done
echo "END;" >> corsair_smr_data_sync.sql
echo >> corsair_smr_data_sync.sql

echo "DROP PROCEDURE IF EXISTS insert_smr_overall_commu;" >> corsair_smr_data_sync.sql
echo "CREATE PROCEDURE insert_smr_overall_commu()" >> corsair_smr_data_sync.sql
echo "BEGIN" >> corsair_smr_data_sync.sql
for ((i=0; i<$LOCAL_CNT; i++))
do
  echo "  INSERT INTO smr_overall_commu SELECT $((i+10000)), comm_id, comm_name, alias, userid, email, phone, introduction, FALSE, TRUE, sync_time" >> corsair_smr_data_sync.sql
  echo "  FROM corsair_lmr_$i.jos_community_admin JOIN corsair_lmr_$i.lmr_commu_patch" >> corsair_smr_data_sync.sql
  echo "  ON lmr_commu_patch.community_id = jos_community_admin.comm_id;" >> corsair_smr_data_sync.sql
done
echo "END;" >> corsair_smr_data_sync.sql
echo >> corsair_smr_data_sync.sql

cat __corsair_smr_data_sync.sql >> corsair_smr_data_sync.sql

echo "CALL sp_fill_data($CROSS_USER_COMMU, 0, 0, 0);" >> corsair_smr_data_sync.sql


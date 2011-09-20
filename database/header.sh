#! /bin/bash

DB_USER='root'
DB_PASSWD='tsinghua'
V_OPTION='-vvv' # manually output progress

LOCAL_CNT=15
check=0
for host in `cat ../node.list`
do
  ((check++))
done
if [ $check -ne $LOCAL_CNT ] ; then
  echo
  echo "ERROR: Number of local nodes ($LOCAL_CNT) != provided addresses in node.list ($check)"
  echo
  exit
fi

LMR_USR_CNT=19366
REAL_LMR_COMMU=512
LMR_COMMU_CNT=$((REAL_LMR_COMMU * LOCAL_CNT))
LMR_USR_COMMU=24253
LMR_GRP_CNT=$REAL_LMR_COMMU
LMR_COMMU_GRP=$LMR_COMMU_CNT

SMR_COMMU_GRP=$((LMR_GRP_CNT * LOCAL_CNT * (LOCAL_CNT / 3)))


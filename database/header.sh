#! /bin/bash

DB_USER='root'
DB_PASSWD='tsinghua'

LOCAL_CNT=3
check=0
for host in `cat node.list`
do
  ((check++))
done
if [ $check -ne $LOCAL_CNT ] ; then
  echo
  echo "ERROR: Number of local nodes ($LOCAL_CNT) != provided addresses in node.list ($check)"
  echo
  exit
fi

LMR_USR_CNT=100 # 19366
LMR_COMMU_CNT=20 # 512
LMR_USR_COMMU=200 # 24253
LMR_GRP_CNT=$LMR_COMMU_CNT
LMR_COMMU_GRP=$LMR_COMMU_CNT

SMR_COMMU_GRP=$((LMR_GRP_CNT * LOCAL_CNT * (LOCAL_CNT - 1)))


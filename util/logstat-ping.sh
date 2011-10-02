#! /bin/bash
ROOT='../log-bak/log-normal-100'
NODE_CNT=10

LOG_FILE="$ROOT/ping-node.log"

echo "# Average rtt" > $LOG_FILE
for ((i=1; i<=$NODE_CNT; ++i))
do
  value=`cat $ROOT/ping-node$i-*.log | awk '
    BEGIN {
      avg=0;
      cnt=0;
      max=0;
      min=100000;
    }
    {
      if ($1=="rtt") {
        split($4, times, "/");        
        ++cnt;
        if (times[2] > max) max=times[2];
        if (cnt != '$i' && times[2] < min)
          min=times[2];
        if (cnt != '$i')
          avg+=times[2];
      }
    }
    END {
      if (cnt != '$NODE_CNT') {
        print "ERROR";
      } else {
        printf "%.3f %.3f", avg/(cnt-1), max - min;
      }
    }'`
  echo "$i $value" >> $LOG_FILE
done

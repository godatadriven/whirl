#!/bin/bash

set +ex

sleep 30

sed -e "s/AWS_SERVER/$AWS_SERVER/g" \
    -e "s/AWS_PORT/$AWS_PORT/g" \
    -e "s/AWS_ACCESS_KEY_ID/$AWS_ACCESS_KEY_ID/g" \
    -e "s/AWS_SECRET_ACCESS_KEY/$AWS_SECRET_ACCESS_KEY/g" \
    -e "s/HIVE_DW_BUCKET/$HIVE_DW_BUCKET/g" \
    -i $HIVE_HOME/conf/core-site.xml

$HIVE_HOME/bin/schematool -dbType derby -initSchema
$HIVE_HOME/hcatalog/sbin/hcat_server.sh start &

sleep 10

#$HIVE_HOME/bin/hiveserver2 --hiveconf hive.root.logger=Info,console &

/usr/bin/tail -f /dev/null

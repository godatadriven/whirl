#!/bin/bash

set +ex

$HIVE_HOME/bin/schematool -dbType derby -initSchema
$HIVE_HOME/hcatalog/sbin/hcat_server.sh start &

sleep 10

#$HIVE_HOME/bin/hiveserver2 --hiveconf hive.root.logger=Info,console &

/usr/bin/tail -f /dev/null

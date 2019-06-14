#!/usr/bin/env bash

source /etc/airflow/functions/date_replacement.sh

echo "======================="
echo "== Prepare mock data =="
echo "======================="

MOCK_DATA_ORIGINAL_DIR=/mock-data       # mounted
MOCK_DATA_WORKING_DIR=${HOME}/working-dir

# /mockdata is mounted, so any action on this folder
# will alter the contents of that folder
# instead, copy the files to a different 'made up' location
mkdir -p $MOCK_DATA_WORKING_DIR
for f in $(find $MOCK_DATA_ORIGINAL_DIR -type f)
do
  cp $f $MOCK_DATA_WORKING_DIR
done

for f in $(find $MOCK_DATA_WORKING_DIR -type f)
do
  # rename zipped files
  if [[ $f =~ \.zip$ ]]; then
    echo "Found zipped file $f, renaming it's contents"
    for child_f in $(zipinfo -1 $f)
    do
      for r in $(replace_date $child_f)
      do
        printf "@ $child_f\n@=$r\n" | zipnote -w $f
      done
    done
  fi

  # rename files with placeholders
  for r in $(replace_date $f)
  do
    if ! [ "$f" = "$r" ]; then
      echo "Renaming $(basename ${f}) to $(basename ${r})"
      mv $f $r
    fi
  done
done

echo "================================="
echo "== Put mock-data on ftp server =="
echo "================================="

export SSHPASS=$SFTP_PASS
sshpass -e sftp -oBatchMode=no -b - $SFTP_USER@ftp-server <<EOF
mput ${MOCK_DATA_WORKING_DIR}/* $SFTP_ROOTDIR/
EOF

#!/usr/bin/env bash

SCRIPT_DIR=$( dirname ${BASH_SOURCE[0]} )
source ${SCRIPT_DIR}/includes/date_replacement.sh

echo "=========================================="
echo "== Prepare mock data ====================="
echo "=========================================="

MOCK_DATA_ORIGINAL_DIR=/mock-data       # mounted
MOCK_DATA_WORKING_DIR=/working-dir

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

echo "===================================================="
echo "== Put mock-data on ftp server ====================="
echo "===================================================="

airflow connections -a --conn_id ftp_server --conn_type SSH --conn_host ftp-server --conn_login $SFTP_USER --conn_port 22 --conn_password $SFTP_PASS
mkdir -p ~/.ssh && ssh-keyscan ftp-server >> ~/.ssh/known_hosts

apt-get install -y sshpass
export SSHPASS=$SFTP_PASS
sshpass -e sftp -oBatchMode=no -b - $SFTP_USER@ftp-server <<EOF
mput /working-dir/* $SFTP_ROOTDIR/
EOF

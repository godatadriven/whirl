#!/usr/bin/env bash

echo "==============================="
echo "== Install timetable plugins =="
echo "==============================="

mkdir -p /tmp/custom_build
sudo apt-get update && sudo apt-get install -y build-essential
pip install ${WHIRL_SETUP_FOLDER}/dag.d/plugins

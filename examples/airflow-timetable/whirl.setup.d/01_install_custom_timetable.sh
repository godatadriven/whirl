#!/usr/bin/env bash
set -e

echo "==============================="
echo "== Install timetable plugins =="
echo "==============================="

mkdir -p /tmp/custom_build
pip install ${WHIRL_SETUP_FOLDER}/dag.d/plugins

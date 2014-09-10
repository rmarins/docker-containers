#!/bin/sh

BASE_DIR="$( dirname "${BASH_SOURCE[0]}" )"

. $BASE_DIR/fsw_allinone.conf
. $BASE_DIR/docker_functions.sh

##################################
#
# Begin
#

echo ""
echo "JBoss FSW All-in-One HA"
echo "======================="
echo ""
echo "Stopping environment..."

# Check if containers are started already
stop_running_containers $BASE_DIR/docker.pid 
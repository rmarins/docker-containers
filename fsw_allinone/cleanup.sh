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

# Stop containers if running
stop_running_containers $BASE_DIR/docker.pid 

# Remove containers
docker rm $FSW_HA_ALLINONE_CONTAINER $FSW_HA_DB_CONTAINER
#!/bin/sh
#

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
echo "Starting environment..."


# Check if required container images exists
check_image_exists ${POSTGRESQL_IMAGE}
check_image_exists ${FSW_HA_SERVER_IMAGE}

# Check if containers are started already
stop_running_containers $BASE_DIR/docker.pid 

#
# Start services
#

# PostgreSQL
echo "   + starting PostgreSQL container"
ipaddr_postgresql=$( start_container $BASE_DIR/docker.pid $FSW_HA_DB_CONTAINER $POSTGRESQL_IMAGE )

# FSW HA All-in-One server (FSW-NODE1, FSW-NODE2, HTTPD, SSHD)
echo "   + starting FSW HA (two nodes, web load balancing, sshd) container"
ipaddr_allinone=$( start_container $BASE_DIR/docker.pid $FSW_HA_ALLINONE_CONTAINER $FSW_HA_SERVER_IMAGE --link ${FSW_HA_DB_CONTAINER}:postgresql.docker.local )
# End
echo ""
cat > $BASE_DIR/docker.info << EOF

Started environment:
  PostgreSQL container named $FSW_HA_DB_CONTAINER with IP $ipaddr_postgresql
  FSW HA All-in-One container named $FSW_HA_ALLINONE_CONTAINER with IP $ipaddr_allinone

EOF

cat $BASE_DIR/docker.info
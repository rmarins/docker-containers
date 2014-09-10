#!/bin/sh

BASE_DIR="$( dirname "${BASH_SOURCE[0]}" )"

. $BASE_DIR/fsw_allinone.conf
. $BASE_DIR/docker_functions.sh

if ! [ -f "$BASE_DIR/software/${FSW_INSTALLER}" ]; then
	echo "File software/${FSW_INSTALLER} not found."
  echo "Please download JBoss Fuse Service Works 6.0.0.GA from http://jboss.org/products#IBP"
  exit 0
fi

if ! [ -f "$BASE_DIR/software/${POSTGRESQL_DRIVER}" ]; then
	echo "File software/${POSTGRESQL_DRIVER} not found."
  exit 0
fi

# Create PostgreSQL container
echo "Creating PostgreSQL container ..."
docker build --rm -q -t $POSTGRESQL_IMAGE $BASE_DIR/../database/postgres/docker

if [ $? -eq 0 ]; then
    echo "DB container built"
else
    echo "Error building DB container"
    exit 0
fi

# Check if container is already started
if [ -f docker.pid ]; then
    echo "Container is already started"
    container_id=$(cat docker.pid)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f docker.pid
fi

# Start PostgreSQL server container
echo "Starting PostgreSQL server ..."
image_postgres=$(docker run -d --name $FSW_HA_DB_CONTAINER $POSTGRESQL_IMAGE)
ip_postgres=$(docker inspect $image_postgres | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_postgres > $BASE_DIR/docker.pid

#
# Create FSW container
#
echo "Creating the JBoss Fuse Service Works 6.0.0 container ..."
cp $BASE_DIR/software/${FSW_INSTALLER} $BASE_DIR/docker
cp $BASE_DIR/software/${POSTGRESQL_DRIVER} $BASE_DIR/docker

cp $BASE_DIR/support/*.ini $BASE_DIR/docker
cp $BASE_DIR/support/mod_cluster.conf $BASE_DIR/docker
cp $BASE_DIR/support/InstallationScript* $BASE_DIR/docker
cp $BASE_DIR/docker/install_fsw.sh-dist $BASE_DIR/docker/install_fsw.sh

sed -i -e "s/__pgserver_docker_local__/${ip_postgres}/g" $BASE_DIR/docker/InstallationScript.xml
sed -i -e "s/__pgserver_docker_local__/${ip_postgres}/g" $BASE_DIR/docker/install_fsw.sh

docker build --rm -q -t $FSW_HA_SERVER_IMAGE $BASE_DIR/docker

container_id=$(cat docker.pid)
echo "Stoping container $container_id..."
docker stop $container_id
rm -f docker.pid

docker commit $FSW_HA_DB_CONTAINER $POSTGRESQL_IMAGE

if [ $? -eq 0 ]; then
    echo "FSW container built"
else
    echo "Error building FSW container"
fi


rm -rf $BASE_DIR/docker/{${FSW_INSTALLER},${POSTGRESQL_DRIVER},*.ini,mod_cluster.conf,install_fsw.sh,InstallationScript*}
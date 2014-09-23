#!/bin/sh

install_required_error() {
  echo ""
  echo "Start environment failed. Run ./install.sh to build the containers."
  echo ""
  exit 1
}

check_image_exists() {
	echo "   + verifying container image: $1"
	docker inspect $1 > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    echo "     [ok]"
	else
	    echo "     [not found]"
	    install_required_error
	fi
}

stop_running_containers() {
	pidfile="$1"
	if [ -f ${pidfile} ]; then
	    container_id=$( cat ${pidfile} )
	    echo "   + stopping containers instances: $container_id"
	    docker stop $container_id > /dev/null 2>&1
	    rm -f docker.pid > /dev/null 2>&1
	fi
}

start_container() {
	pidfile="$1"
	container_name="$2"
	container_image="$3"
	shift 3
	container_run_opts="$@"
	container_id=""
	# start existing container or create a new one
	docker inspect $container_name > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		container_id=$( docker start $container_name )
	else
		container_id=$( docker run -d --name $container_name $container_run_opts $container_image )
	fi
  container_ipaddr=$( docker inspect $container_id | grep IPAddress | awk '{print $2}' | tr -d '",' )
  echo -n "$container_id " >> $pidfile

  echo -n "$container_ipaddr"
}
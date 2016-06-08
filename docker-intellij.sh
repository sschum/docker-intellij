#!/bin/bash

if [ -n "$1" ]; then
	WORKSPACE=$1
	WORKSPACE_VOLUME="--volume $WORKSPACE:/home/intellij/workspace"
fi

DOCKER_IMAGE="rainu/intellij"
CUR_USER_ID=$(id -u)
CUR_USER_GID=$(id -g)
DOCKER_NAME="intellij-$CUR_USER_ID-$(echo $WORKSPACE | md5sum | cut -b -8)"

HOST_PROFILE="$HOME/.docker/$DOCKER_IMAGE"
HOST_SSH="$HOME/.ssh/"

read -r -d '' DOCKER_COMMON_RUN_PARAMS <<EOF
--env LANG=$LANG 
--env LANGUAGE=$LANGUAGE 
--env DISPLAY=$DISPLAY
--env HOST_USER_UID=$CUR_USER_ID
--env HOST_USER_GID=$CUR_USER_GID
--volume /tmp/.X11-unix:/tmp/.X11-unix 
--volume $HOST_PROFILE:/home/intellij/.IntelliJIdea2016.1
--volume $HOST_SSH:/home/intellij/.ssh:ro
$WORKSPACE_VOLUME
EOF

execute()
{
	SCRIPT=$(mktemp)

	echo $@ > $SCRIPT
	chmod +x $SCRIPT

	$SCRIPT
	RC=$?
	rm $SCRIPT

	return $RC
}

DOCKER_CONTAINER_EXISTS=$(docker ps -a | grep $DOCKER_NAME | wc -l)

if [ "$DOCKER_CONTAINER_EXISTS" == "0" ]; then
	mkdir -p $HOST_PROFILE
	chmod 777 $HOST_PROFILE

	execute docker run \
	    --detach \
	    --name "$DOCKER_NAME" \
	    $DOCKER_COMMON_RUN_PARAMS \
	    $DOCKER_IMAGE
else
	execute docker start $DOCKER_NAME
fi

execute docker attach $DOCKER_NAME
exit $?
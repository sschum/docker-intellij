#!/bin/bash

####
# Variables
####

DOCKER_IMAGE="rainu/intellij"

CUR_USER_ID=$(id -u)
CUR_USER_GID=$(id -g)

HOST_PROFILE=$(echo "$HOME/.docker/$DOCKER_IMAGE" | sed 's/:/-/g')
HOST_SSH="$HOME/.ssh/"

INTELLIJ_ARGS=""
DOCKER_ARGS=""

DOCKER_NAME="intellij-$CUR_USER_ID"
read -r -d '' DOCKER_RUN_PARAMS <<EOF
--env LANG=$LANG
--env LANGUAGE=$LANGUAGE
--env DISPLAY=$DISPLAY
--env HOST_USER_UID=$CUR_USER_ID
--env HOST_USER_GID=$CUR_USER_GID
--volume /tmp/.X11-unix:/tmp/.X11-unix
--volume /usr/share/icons:/usr/share/icons:ro
--volume /usr/share/fonts:/usr/share/fonts:ro
--volume $HOST_PROFILE:/home/intellij/.IntelliJIdea2016.2
EOF

####
# Functions
####

execute() {
	SCRIPT=$(mktemp)

	echo $@ > $SCRIPT
	chmod +x $SCRIPT

	$SCRIPT
	RC=$?
	rm $SCRIPT

	return $RC
}

showHelp() {
echo 'Starts the IntellJ docker container.

docker-intellij.sh [OPTIONS...]

Options:
	-h, -help
		Shows this help text
	-w, --workspace
		Mount this directory as the which contains the projects
	-m, --maven
		Mount this directory as the maven directory
	-s, --ssh
		Mount this directory containing the ssh-key(s)
	-D, --docker
		Additional argument to docker command
	-x, --xarg
		Argument(s) for the underlying IntelliJ
'
	exit 0
}

readArguments() {
	while [[ $# > 0 ]]; do
		key="$1"

		case $key in
		    -w|--workspace)
		    DOCKER_RUN_PARAMS=$DOCKER_RUN_PARAMS" --volume $2:/home/intellij/workspace/"
		    DOCKER_NAME=$DOCKER_NAME"-$(echo $2 | md5sum | cut -b -8)"
		    shift
		    ;;
		    -m|--maven)
		    DOCKER_RUN_PARAMS=$DOCKER_RUN_PARAMS" --volume $2:/home/intellij/.m2/"
		    shift
		    ;;
		    -s|--ssh)
		    HOST_SSH="$2"
		    shift
		    ;;
		    -x|-xargs)
		    INTELLIJ_ARGS=$INTELLIJ_ARGS" $2"
		    shift
		    ;;
		    -D|--docker)
		    DOCKER_ARGS=$DOCKER_ARGS" $2"
		    shift
		    ;;
		    -h|--help)
		    showHelp
		    ;;
		    *)
			    # unknown option
		    ;;
		esac
		shift # past argument or value
	done

	DOCKER_RUN_PARAMS=$DOCKER_RUN_PARAMS" --volume $HOST_SSH:/home/intellij/.ssh/"
}

####
# Main
####

readArguments "$@"

DOCKER_CONTAINER_EXISTS=$(docker ps -a | grep $DOCKER_NAME | wc -l)

if [ "$DOCKER_CONTAINER_EXISTS" == "0" ]; then
	mkdir -p $HOST_PROFILE
	chmod 777 $HOST_PROFILE

	execute docker run \
	    --detach \
	    --name "$DOCKER_NAME" \
	    $DOCKER_RUN_PARAMS \
	    $DOCKER_ARGS \
	    $DOCKER_IMAGE \
	    $INTELLIJ_ARGS
else
	execute docker start $DOCKER_NAME
fi

execute docker attach $DOCKER_NAME
exit $?

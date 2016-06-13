#!/bin/bash

INTELLIJ_BIN="/opt/intellij/bin/idea.sh"
USER="intellij"
USER_HOME="/home/intellij"

PATH=$PATH:/home/intellij/bin/

#set uid/gui to hosts user spec
usermod -u $HOST_USER_UID $USER
usermod -g $HOST_USER_GID $USER

su intellij -c "export PATH=$PATH; cd ~; /opt/intellij/bin/idea.sh $@"

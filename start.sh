#!/bin/sh

INTELLIJ_BIN="/opt/intellij/bin/idea.sh"

PATH=$PATH:/home/$USERNAME/bin/

#set uid/gui to hosts user spec
cat /etc/passwd  | grep -v $USERNAME > /etc/passwd
echo "$USERNAME:x:$HOST_USER_UID:$HOST_USER_GID:IntelliJ User,,,:/home/$USERNAME:/bin/sh" >> /etc/passwd

#mod group id of intellij-group
cat /etc/group  | grep -v $GROUPNAME > /etc/group
echo "$GROUPNAME:x:$HOST_USER_GID:" >> /etc/group

#fix permission
chown $USERNAME:$GROUPNAME -R /home/$USERNAME
chown $USERNAME:$GROUPNAME -R /opt/intellij
chown $USERNAME:$GROUPNAME -R /usr/local/go

su intellij -c "export PATH=$PATH; cd ~; /opt/intellij/bin/idea.sh $@"

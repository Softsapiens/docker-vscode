#!/usr/bin/env bash

echo "You are connecting with User ${MYUSERNAME}"

ID=$(id -u)
#If we are root and we have give a MYUID different from default
if [ "$ID" -eq "0" ] && [ $MYUID != "" ]; then
    echo "Creating user $MYUSERNAME"
    groupadd -g $MYGID myusers || true
    useradd --uid $MYUID --gid $MYGID -s /bin/bash --home /home/$MYUSERNAME $MYUSERNAME
    echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} 
    sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME}
    sudo chown ${MYUSERNAME}:${MYGID} -R /home/${MYUSERNAME}
fi

echo "Starting command [$@]"
su ${MYUSERNAME} -c "$@"

echo "end"

exit 0

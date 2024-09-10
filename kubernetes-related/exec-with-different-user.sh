#!/bin/bash

POD_NAME=$1
CONTAINER_NAME=$2
USERNAME=$3

kubectl exec -it $POD_NAME -c $CONTAINER_NAME -- su -s /bin/bash $USERNAME
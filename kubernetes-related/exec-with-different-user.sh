#!/bin/bash

# Pass the pod name, container name and username as arguments
POD_NAME=my-pod
CONTAINER_NAME=my-container
USERNAME=my-user

kubectl exec -it $POD_NAME -c $CONTAINER_NAME -- su -s /bin/bash $USERNAME
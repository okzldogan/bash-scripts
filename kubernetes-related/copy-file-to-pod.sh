#!/bin/bash

# Pass the local file path, pod name and container name as arguments

LOCAL_FILE_PATH=/mypath/myfile.txt
POD_NAME=my-pod
CONTAINER_NAME=my-container
NAMESPACE=my-namespace


kubectl cp $LOCAL_FILE_PATH $POD_NAME/path-inside-pod -c $CONTAINER_NAME -n $NAMESPACE

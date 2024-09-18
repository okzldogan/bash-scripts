#!/bin/bash

NODE_NAME=$1

drain_and_delete_node() {
    
    echo "Starting the process of draining & then deleting node $NODE_NAME"
    echo "Draining node $NODE_NAME"
    kubectl cordon $NODE_NAME
    sleep 1
    DRAIN_NODE=$(kubectl drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data)

    # Check if the drain command was successful
    if [ $? -eq 0 ]; then
        echo "Deleting node $NODE_NAME"
        sleep 1
        kubectl delete node $NODE_NAME
    else
        echo "Error while draining node $NODE_NAME"
    fi
}


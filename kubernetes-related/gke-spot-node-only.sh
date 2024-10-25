CLUSTER_NAME=$1

# Get node names with kubectl command

NON_SPOT_NODE_NAMES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'| tr " " "\n" | grep -v "spot")

echo -e "The non-spot nodes are: \n$NON_SPOT_NODE_NAMES"
echo "--------------------"

# Get the current node size of highmem--pool

GET_HIGMEM_NON_SPOT_NODEPOOL_SIZE=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'| tr " " "\n" | grep "highmem-pool" | wc -l)

# Get the current node size of highmem-spot-pool

GET_HIGMEMSPOT_NODEPOOL_SIZE=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'| tr " " "\n" | grep "highmem-spot-pool" | wc -l)

# Set the required highmem node size by adding the GET_HIGMEM_NON_SPOT_NODEPOOL_SIZE and GET_HIGMEMSPOT_NODEPOOL_SIZE

REQUIRED_HIGMEM_NODE_SIZE=$(($GET_HIGMEM_NON_SPOT_NODEPOOL_SIZE + $GET_HIGMEMSPOT_NODEPOOL_SIZE))

# If GET_HIGMEMSPOT_NODEPOOL_SIZE is greater than and equal to 1
if [ $GET_HIGMEM_NON_SPOT_NODEPOOL_SIZE -eq 0 ]; then
    echo "Node pool highmem-NON-spot-pool is already running with $GET_HIGMEM_NON_SPOT_NODEPOOL_SIZE node"
else
    echo "Resizing node pool highmem-spot-pool to $REQUIRED_HIGMEM_NODE_SIZE node(s)"
    # Resize highmem-spot-pool nodepool to $REQUIRED_HIGMEM_NODE_SIZE node 

    # If CLUSTER_NAME contains "dev" then use the command with "--zone" flag else use the command "--region" flag

    if [[ $CLUSTER_NAME == *"dev"* ]]; then
        RESIZE_HIGMEMSPOT_NODEPOOL=$(gcloud container clusters resize $CLUSTER_NAME --node-pool highmem-spot-pool \
            --num-nodes $REQUIRED_HIGMEM_NODE_SIZE  \
            --project=$CLUSTER_NAME \
            --zone=europe-west1-c \
            --quiet)
    else
        RESIZE_HIGMEMSPOT_NODEPOOL=$(gcloud container clusters resize $CLUSTER_NAME --node-pool highmem-spot-pool \
            --num-nodes $REQUIRED_HIGMEM_NODE_SIZE \
            --project=$CLUSTER_NAME \
            --region=europe-west1 \
            --quiet)
    fi

    if [ $? -eq 0 ]; then
        HIGHMEM_POOL_NODE_NAMES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'| tr " " "\n" | grep "highmem-pool")
        for node in $HIGHMEM_POOL_NODE_NAMES
        do
            echo "Draining node $node"
            kubectl cordon $node
            sleep 1
            DRAIN_NODE=$(kubectl drain $node --ignore-daemonsets --delete-emptydir-data)
            if [ $? -eq 0 ]; then
                echo "Deleting node $node"
                sleep 1
                kubectl delete node $node
            else
                echo "Error while draining node $node"
            fi
        done

    else

        echo "Error while resizing node pool highmem-spot-pool to $REQUIRED_HIGMEM_NODE_SIZE node(s)"
    fi

fi

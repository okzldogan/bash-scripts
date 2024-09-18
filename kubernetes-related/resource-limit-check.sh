#!/bin/bash

# Pass the namespace, CPU limit and Memory limit as arguments
NAMESPACE=mynamespace

# Insert values without the "m" and "Mi" suffix
CPU_LIMIT_TO_CHECK=mycpu-limit
MEMORY_LIMIT_TO_CHECK=mymemory-limit

# Get all the deployments in the github-runner namespace

DEPLOYMENTS_IN_NAMESPACE=$(kubectl get deployments -o jsonpath='{.items[*].metadata.name}' -n $NAMESPACE)

# Create a directory with the namespace name

mkdir $NAMESPACE-deployments


for deployment in $DEPLOYMENTS_IN_NAMESPACE
do
  kubectl get deployment $deployment -n $NAMESPACE -o yaml > ./$NAMESPACE-deployments/$deployment.yaml
done


FILE_NAMES=$(ls ./$NAMESPACE-deployments)
for file in $FILE_NAMES
do
    # Check if the "cpu:" and "memory:" lines exist
    CPU=$(grep -i "cpu:" ./$NAMESPACE-deployments/$file| tr " " "\n" | sort -nr | head -1)
    MEMORY=$(grep -i "memory:" ./$NAMESPACE-deployments/$file| tr " " "\n" | sort -nr | head -1)


    FILE_NAME=$(echo $file | awk -F "/" '{print $3}')

    for name in $FILE_NAME
    do
        # if the CPU value is empty, echo the file
        if [ -z $CPU ]
        then
        echo "$name does not have CPU value"
        else
            # Remove the "m" from the CPU value
            CPU=${CPU::-1}

            if [ $CPU -gt $CPU_LIMIT_TO_CHECK ]
            then
                echo "$name CPU is above $CPU_LIMIT_TO_CHECK\M, CPU: $CPU"
            fi
        fi

        # if the MEMORY value is empty, echo the file
        if [ -z $MEMORY ]
        then
        echo "$name does not have MEMORY value"
        else
            # Remove the "Mi" from the MEMORY value
            MEMORY=${MEMORY::-2}

            if [ $MEMORY -gt $MEMORY_LIMIT_TO_CHECK ]
            then
                echo "$name MEMORY is above $MEMORY_LIMIT_TO_CHECK\Mi, MEMORY: $MEMORY"
            fi
        fi
    done
done

#!/bin/bash

NAMESPACE=$1

# Get the deployment names

DEPLOYMENT_NAMES=$(kubectl get deployments -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

# Scale the replicas to 0 for all deployments

for deployment in $DEPLOYMENT_NAMES; do
    kubectl scale deploy $deployment --replicas=0 -n $NAMESPACE
done


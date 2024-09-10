#!/bin/bash

BILLING_ACCOUNT_ID=$1

API_NAME=$2
# Example
# API_NAME=maps

# Get the list of projects with googlemaps API enabled

BILLING_ENABLED_PROJECTS=$(gcloud billing projects list --billing-account=$BILLING_ACCOUNT_ID --format="value(projectId)")

for PROJECT in $BILLING_ENABLED_PROJECTS; do
    ENABLED_API_NAME=$(gcloud services list --enabled --project $PROJECT | grep "$API_NAME" | awk '{print $1}')
    if [ -n "$ENABLED_API_NAME" ]; then
        echo $PROJECT >> api-enabled-projects.csv
    fi
done

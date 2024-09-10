#!/bin/bash

BILLING_ACCOUNT_ID=$1

# Get the list of all GCP Projects where billing is enabled

BILLING_ENABLED_PROJECTS=$(gcloud billing projects list --billing-account=$BILLING_ACCOUNT_ID --format="value(projectId)")


# Loop through all BILLING_ENABLED_PROJECTS and get the editors

for PROJECT in $BILLING_ENABLED_PROJECTS; do
    PROJECT_EDITORS=$(gcloud projects get-iam-policy $PROJECT --flatten="bindings[].members[]" \
    --filter="bindings.role=roles/editor" --format="value(bindings.members)")
    # Write the editors to a CSV file
    for editor in $PROJECT_EDITORS; do
        echo "$PROJECT,$editor" >> editors.csv
    done
done

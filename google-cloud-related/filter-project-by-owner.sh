#!/bin/bash

PROJECT_OWNER_EMAIL_WITH_USER_TYPE=$1
# Example User
# PROJECT_OWNER_EMAIL_WITH_USER_TYPE=serviceAccount:my-serviceAccount@my-project.gserviceaccount.com

# Get the list of all GCP Projects

ALL_GCP_PROJECTS=$(gcloud projects list --format="value(projectId)")

# Loop through all projects and check the owner

for PROJECT in $ALL_GCP_PROJECTS; do
    PROJECT_OWNERS=$(gcloud projects get-iam-policy $PROJECT --flatten="bindings[].members[]" \
    --filter="bindings.role=roles/owner" --format="value(bindings.members)")

    if [[ $PROJECT_OWNERS == *"$PROJECT_OWNER_EMAIL_WITH_USER_TYPE"* ]] ; then
        echo "The $PROJECT is owned by $PROJECT_OWNER_EMAIL_WITH_USER_TYPE"
    fi
done

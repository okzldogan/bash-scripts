#!/bin/bash

# Get all the GCP projects

export ALL_PROJECTS=$(gcloud projects list --format='get(projectId)')

# Check if a project has any buckets

for project in $ALL_PROJECTS; do
    echo "Checking if the project $project has any buckets."
    # If the project has a bucket, get the name of the bucket
    export BUCKET_NAMES=$(gsutil ls -p $project)
    # If BUCKET_NAMES is not empty, get the size of the bucket
    if [ -n "$BUCKET_NAMES" ]; then
        for bucket in $BUCKET_NAMES; do
            export BUCKET_SIZE=$(gsutil du -s $bucket | awk '{print $1}' | awk '{ GB = $1 / 1024 / 1024 / 1024 ; print GB "GB" }')
            echo $project, $bucket, $BUCKET_SIZE >> bucket-size.csv
        done
    else
        echo "The project $project does not have any buckets."
    fi
done


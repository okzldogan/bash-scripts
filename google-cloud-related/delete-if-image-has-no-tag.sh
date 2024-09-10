#!/bin/bash

ARTIFACTS_REGISTRY_NAME=$1
# Example 
# ARTIFACTS_REGISTRY_NAME=europe-docker.pkg.dev/my-project/my-docker-repo

# Get all images in spi-sme-staging docker repo

export DOCKER_IMAGES=$(gcloud artifacts docker images list $ARTIFACTS_REGISTRY_NAME --format='value(IMAGE)'| sort -u| cut -f 4 -d "/")

# for each image in DOCKER_IMAGES check if there is a tag

for images in $DOCKER_IMAGES; do
    echo "checking tags for $images"
    IMAGE_SHAS_WITHOUT_TAGS=$(gcloud artifacts docker images list $ARTIFACTS_REGISTRY_NAME/$images --include-tags --format='value(DIGEST,TAGS)'|grep -E "\s$")
    for sha in $IMAGE_SHAS_WITHOUT_TAGS; do
        echo "deleting image $images:$sha"
        gcloud artifacts docker images delete $ARTIFACTS_REGISTRY_NAME/$images@$sha --quiet
    done
done


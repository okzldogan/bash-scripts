NAMESPACE=$1

kubectl get ns $NAMESPACE -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -
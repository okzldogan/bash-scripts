#!/bin/bash

env=my-env

MY_ARRAY=( "my_key1:my_value1_$env" "my_key2:my_value2_$env" "my_key3:my_value3_$env")


for mapping in "${MY_ARRAY[@]}"
do
    echo "key: ${mapping%%:*}"
    echo "value: ${mapping##*:}"
done



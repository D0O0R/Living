#!/bin/bash

# Get command line parameters
# -c config
#       The format should be "account_id:namespace_id:access_token"
# -k key
# -v value
# -h help
while getopts "c:k:v:h" opt
do
    case $opt in
        c)
            c=${OPTARG}
        ;;
        k)
            k=${OPTARG}
        ;;
        v)
            v=${OPTARG}
        ;;
        h)
            echo "ckv.sh -c config -k key [-v value]"
            exit 0
        ;;
    esac

done

if [ ! $c ] ; then
    if [ ! $CKV_CONFIG ] ; then
        echo "config can not be empty"
        exit 1
    else
        c=$CKV_CONFIG
    fi
fi

arr=(${c//:/ })
account_id=${arr[0]}
namespace_id=${arr[1]}
access_token=${arr[2]}

if [ ! $account_id ] || [ ! $namespace_id ] || [ ! $access_token ] ; then
    echo "Config format error: The format should be "account_id:namespace_id:access_token""
    exit 1
fi

if [ ! $k ] ; then
    echo "key can not be empty"
    exit 1
fi

# When value is empty, query the value of key, otherwise update the value of key
if [ ! $v ] ; then
    curl -X GET "https://api.cloudflare.com/client/v4/accounts/$account_id/storage/kv/namespaces/$namespace_id/values/$k" -H "Authorization: Bearer $access_token" -H "Content-Type:application/json" 2>/dev/null
else
    curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$account_id/storage/kv/namespaces/$namespace_id/values/$k" -H "Authorization: Bearer $access_token" -H 'Content-Type: multipart/form-data' --form metadata={} --form value=$v 2>/dev/null
fi

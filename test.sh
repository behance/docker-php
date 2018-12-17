#!/bin/bash -e

set -o pipefail

#-----------------------------------------------------------------------
# Performs a simple integration test
#
# - Build each variant
# - Assert major, minor language versions from default phpinfon page
# - Create 98MB file for upload (compose sets upload limit to 100MB)
# - TODO: create goss tests command probe while containers are up
#-----------------------------------------------------------------------

MACHINE=$1

if [ -z "$1" ]; then
    printf "Basic integration script for docker-php and its variants\n\n"
    printf "Usage:\n\ttest.sh [docker-machine ip]\n"
    exit 1;
fi

docker-compose build 56
docker-compose build 70
docker-compose build 71
docker-compose build 72
docker-compose build 72-alpine

docker-compose up -d
sleep 5
docker-compose ps

curl $MACHINE:8080 | grep "PHP Version 5.6."
curl $MACHINE:8081 | grep "PHP Version 7.0."
curl $MACHINE:8082 | grep "PHP Version 7.1."
curl $MACHINE:8083 | grep "PHP Version 7.1."
curl $MACHINE:8084 | grep "PHP Version 7.2."

# Create a junk file that will test container uploading capability
dd if=/dev/zero of=tmp.txt count=100000 bs=1024

# Though the file is uploaded, the response message is still the default phpinfo page
curl --form upload=@tmp.txt $MACHINE:8080 | grep "PHP Version 5.6." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8081 | grep "PHP Version 7.0." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8082 | grep "PHP Version 7.0." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8083 | grep "PHP Version 7.1." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8084 | grep "PHP Version 7.2." > /dev/null

# Cleanup
rm tmp.txt

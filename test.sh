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

if [ -z "$1" ]
then
  printf "Basic integration script for docker-php and its variants.\n\nUsage:\n\ttest.sh [docker-machine ip]\n"
  exit 1;
fi

docker-compose build ubuntu
docker-compose build edge
docker-compose build legacy
docker-compose build alpine
docker-compose up -d
sleep 5
docker-compose ps

curl $MACHINE:8080 | grep "PHP Version 7.0."
curl $MACHINE:8081 | grep "PHP Version 7.0."
curl $MACHINE:8082 | grep "PHP Version 7.1."
curl $MACHINE:8083 | grep "PHP Version 5.6."
dd if=/dev/zero of=tmp.txt count=100000 bs=1024
curl --form upload=@tmp.txt $MACHINE:8080 | grep "PHP Version 7.0." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8081 | grep "PHP Version 7.0." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8082 | grep "PHP Version 7.1." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8083 | grep "PHP Version 5.6." > /dev/null

rm tmp.txt

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
docker-compose build 73

docker-compose up -d
sleep 5
docker-compose ps

curl $MACHINE:8080 | grep "PHP Version 5.6."
curl $MACHINE:8081 | grep "PHP Version 7.0."
curl $MACHINE:8082 | grep "PHP Version 7.1."
curl $MACHINE:8083 | grep "PHP Version 7.2."
curl $MACHINE:8084 | grep "PHP Version 7.2."
curl $MACHINE:8085 | grep "PHP Version 7.3."

# Create a junk file that will test container uploading capability
dd if=/dev/zero of=tmp.txt count=100000 bs=1024

# Though the file is uploaded, the response message is still the default phpinfo page
curl --form upload=@tmp.txt $MACHINE:8080 | grep "PHP Version 5.6." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8081 | grep "PHP Version 7.0." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8082 | grep "PHP Version 7.1." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8083 | grep "PHP Version 7.2." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8084 | grep "PHP Version 7.2." > /dev/null
curl --form upload=@tmp.txt $MACHINE:8085 | grep "PHP Version 7.3." > /dev/null

# Error exit codes in dgoss do not bubble up to the runner.
# In order to work around this we need to increment $i.
i=0

echo "Running Runtime Test for 5.6"
GOSSPATH=goss GOSS_FILES_PATH=runtime-tests/newrelic/56/ ./dgoss run -e REPLACE_NEWRELIC_APP="abcefg" -e REPLACE_NEWRELIC_LICENSE="hijklmno" -e NEWRELIC_TRACING_ENABLED="true" dockerphp_56 || ((i++))
echo "Running Runtime Test for 7.0"
GOSS_PATH=goss GOSS_FILES_PATH=runtime-tests/newrelic/70/ ./dgoss run -e REPLACE_NEWRELIC_APP="abcdefg" -e REPLACE_NEWRELIC_LICENSE="hijklmno" -e NEWRELIC_TRACING_ENABLED="true" dockerphp_70 || ((i++))
echo "Running Runtime Test for 7.1"
GOSS_PATH=goss GOSS_FILES_PATH=runtime-tests/newrelic/71/ ./dgoss run -e REPLACE_NEWRELIC_APP="abcdefg" -e REPLACE_NEWRELIC_LICENSE="hijklmno" -e NEWRELIC_TRACING_ENABLED="true" dockerphp_71 || ((i++))
echo "Running Runtime Test for 7.2"
GOSS_PATH=goss GOSS_FILES_PATH=runtime-tests/newrelic/72/ ./dgoss run -e REPLACE_NEWRELIC_APP="abcdefg" -e REPLACE_NEWRELIC_LICENSE="hijklmno" -e NEWRELIC_TRACING_ENABLED="true" dockerphp_72 || ((i++))
echo "Running Runtime Test for 7.2-alpine"
GOSS_PATH=goss GOSS_FILES_PATH=runtime-tests/newrelic/72-alpine/ ./dgoss run -e REPLACE_NEWRELIC_APP="abcdefg" -e REPLACE_NEWRELIC_LICENSE="hijklmno" -e NEWRELIC_TRACING_ENABLED="true" dockerphp_72-alpine || ((i++))
echo "Running Runtime Test for 7.3"
GOSS_PATH=goss GOSS_FILES_PATH=runtime-tests/newrelic/73/ ./dgoss run -e REPLACE_NEWRELIC_APP="abcdefg" -e REPLACE_NEWRELIC_LICENSE="hijklmno" -e NEWRELIC_TRACING_ENABLED="true" dockerphp_73 || ((i++))

# Cleanup
rm tmp.txt

exit $i

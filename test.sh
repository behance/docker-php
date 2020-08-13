#!/bin/bash -e

set -o pipefail

#-----------------------------------------------------------------------
# Performs a simple integration test
#
# - Build each variant
# - Assert major, minor language versions from default phpinfon page
# - Create 98MB file for upload (compose sets upload limit to 100MB)
# - Run goss tests command probe while containers are up
#-----------------------------------------------------------------------

MACHINE=$1
CONTAINER_PORT=8080
PREFIX="==>"

if [ -z "$1" ]; then
    printf "Basic integration script for docker-php and its variants\n\n"
    printf "Usage:\n\ttest.sh [docker-machine ip]\n"
    exit 1;
fi

if [ ! $PHP_VARIANT ]; then
  echo "Missing PHP_VARIANT environment variable"
  exit 1
fi

# Distinguish between naming types
VARIANT_NAME=$PHP_VARIANT
DOCKERFILE_NAME="Dockerfile-${PHP_VARIANT}"

# Removes suffix for -alpine variant if it has one
PHP_VERSION=${PHP_VARIANT%"-alpine"}
DATE=`date '+%H-%M-%S'`
DOCKER_TAG="${PHP_VERSION}-${DATE}"
DOCKER_NAME="${VARIANT_NAME}-${DATE}"

# ==> Cleanup routine
# CI environments are ephemeral, but  local
# environments are not
function finish {
  echo "${PREFIX} Cleaning up ephemeral resources, safe to ignore any failures"
  # Stop the container if it is running
  docker kill $DOCKER_NAME 2>&1 > /dev/null

  # Remove the tag if it exists
  docker rmi -f $DOCKER_TAG 2>&1 > /dev/null
}

trap finish EXIT


echo "${PREFIX} Building out variant ${VARIANT_NAME}"
echo "${PREFIX} PHP Version: ${PHP_VERSION}"
echo "${PREFIX} Dockerfile: ${DOCKERFILE_NAME}, using temporary tag ${DOCKER_TAG}"

printf "${PREFIX} Building the container\n"
docker build -t $DOCKER_TAG -f $DOCKERFILE_NAME .

printf "${PREFIX} Running container in background\n"
docker run \
  --name=$DOCKER_NAME \
  --env-file=./.test.env \
  -p "${CONTAINER_PORT}:${CONTAINER_PORT}" \
  -d \
  -t "${DOCKER_TAG}:latest"

printf "${PREFIX} Waiting for container to boot\n"
sleep 5

echo "${PREFIX} Check default response, including PHP version identification"
curl "${MACHINE}:${CONTAINER_PORT}" | grep "PHP Version ${PHP_VERSION}."

echo "${PREFIX} Create a random file to upload"
dd if=/dev/zero of=tmp.txt count=100000 bs=1024

echo "${PREFIX} Send uploaded file"
curl --form upload=@tmp.txt "${MACHINE}:${CONTAINER_PORT}" \
  | grep "PHP Version ${PHP_VERSION}." > /dev/null

echo "${PREFIX} Perform startup tests"
GOSS_PATH=goss \
GOSS_SLEEP=5 \
GOSS_FILES_PATH="runtime-tests/startup/${PHP_VARIANT}/" \
./dgoss run \
  "${DOCKER_TAG}:latest"

echo "${PREFIX} Perform NewRelic runtime tests"
GOSS_PATH=goss \
GOSS_FILES_PATH="runtime-tests/newrelic/${PHP_VARIANT}/" \
./dgoss run \
  -e REPLACE_NEWRELIC_APP="abcdefg" \
  -e REPLACE_NEWRELIC_LICENSE="hijklmno" \
  -e NEWRELIC_TRACING_ENABLED="true" \
  -e NEWRELIC_LOGLEVEL="verbosedebug" \
  -e NEWRELIC_SPECIAL="debug_autorum" \
  "${DOCKER_TAG}:latest"

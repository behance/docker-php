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
INTERNAL_PORT=8080
PREFIX="==>"
BASE_NAME="docker-php"

if [[ -z "$1" ]]; then
    printf "Basic integration script for docker-php and its variants\n\n"
    printf "Usage:\n\ttest.sh [docker-machine ip]\n"
    exit 1
fi

if [[ ! $PHP_VARIANT ]]; then
  echo "Missing PHP_VARIANT environment variable"
  exit 1
fi

# Required for dgoss execution, below
if [[ ! -n "$GOSS_PATH" ]]; then
  [ -f $(which goss) ]  || { echo 'goss not found, pass GOSS_PATH'; exit 1; }
  GOSS_PATH=$(which goss)
fi

if [[ ! -n "$DGOSS_PATH" ]]; then
  [ -f $(which dgoss) ]  || { echo 'dgoss not found, pass DGOSS_PATH'; exit 1; }
  DGOSS_PATH=$(which dgoss)
fi

# Distinguish between naming types
VARIANT_NAME=$PHP_VARIANT
DOCKERFILE_NAME="Dockerfile-${PHP_VARIANT}"

# Removes suffix for -alpine variant if it has one
PHP_VERSION=${PHP_VARIANT%"-alpine"}
TEST_STRING="PHP Version ${PHP_VERSION}."
PLATFORM="${PLATFORM:=linux/amd64}"

# Since containers may or may not be against the same docker engine, create a matrix-unique tag name for outputs
TAG_NAME="${BASE_NAME}-${VARIANT_NAME}-${PLATFORM}"
# Formats as lowercase
TAG_NAME=$(echo $TAG_NAME | tr '[:upper:]' '[:lower:]')
# Removes slashes
TAG_NAME=$(echo $TAG_NAME | sed 's/\///')

echo "${PREFIX} Variant ${VARIANT_NAME}"
echo "${PREFIX} PHP Version: ${PHP_VERSION}"
echo "${PREFIX} Dockerfile: ${DOCKERFILE_NAME}"
echo "${PREFIX} Tag ${TAG_NAME}"
echo "${PREFIX} Platform: ${PLATFORM}"

printf "${PREFIX} Building container\n"

printf "${PREFIX} using goss (${GOSS_PATH})\n"
printf "${PREFIX} using dgoss (${DGOSS_PATH})\n"

docker buildx build --platform $PLATFORM --iidfile $TAG_NAME -t $TAG_NAME -f $DOCKERFILE_NAME .

# NOTE: multi-arch builds may not be accessible by docker tag, instead target by ID
BUILD_SHA=$(cat ./$TAG_NAME)

# Remove sha256: from tag identifier
BUILD_SHA=$(echo $BUILD_SHA | sed 's/sha256\://')

printf "${PREFIX} Running container in background\n"
CONTAINER_ID=$(docker run --rm --platform $PLATFORM --env-file ./.test.env -p $INTERNAL_PORT -d $BUILD_SHA)
CONTAINER_PORT=$(docker inspect --format '{{ (index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort }}' $CONTAINER_ID)

printf "${PREFIX} Waiting for container to boot\n"
sleep 5

# ==> Cleanup routine
# CI environments may be ephemeral, but local environments are not
function finish {
  echo "${PREFIX} Cleaning up ephemeral resources, safe to ignore any failures"
  # Stop the container if it is running
  docker kill $CONTAINER_ID 2>&1 > /dev/null

  # Remove the tag if it exists
  docker rmi -f $BUILD_SHA 2>&1 > /dev/null
  rm ./$TAG_NAME
}

trap finish EXIT

# -------------------------------------------------------------
echo "${PREFIX} Check default response, including PHP version identification"
curl "${MACHINE}:${CONTAINER_PORT}" | grep "${TEST_STRING}"

echo "${PREFIX} Create a random file to upload"
dd if=/dev/zero of=tmp.txt count=100000 bs=1024

echo "${PREFIX} Send uploaded file"
curl --form upload=@tmp.txt "${MACHINE}:${CONTAINER_PORT}" \
  | grep "${TEST_STRING}" > /dev/null

# -------------------------------------------------------------
echo "${PREFIX} Perform startup tests"

GOSS_FILES_PATH="runtime-tests/startup/" \
GOSS_SLEEP=5 \
$DGOSS_PATH run --rm $BUILD_SHA

# -------------------------------------------------------------
echo "${PREFIX} Perform NewRelic runtime tests"

GOSS_FILES_PATH="runtime-tests/newrelic/" \
GOSS_SLEEP=5 \
$DGOSS_PATH run --rm \
  -e REPLACE_NEWRELIC_APP="abcdefg" \
  -e REPLACE_NEWRELIC_LICENSE="hijklmno" \
  -e NEWRELIC_TRACING_ENABLED="true" \
  -e NEWRELIC_LOGLEVEL="verbosedebug" \
  -e NEWRELIC_SPECIAL="debug_autorum" \
  $BUILD_SHA

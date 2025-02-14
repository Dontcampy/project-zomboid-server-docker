#!/bin/bash

########################333333##################
##                                            ##
## This script has not been tested yet.       ##
## Waiting for a new server version to do it. ##
##                                            ##
########################333333##################

DOCKER_IMAGE="dont39/project-zomboid-dedicated-server"
PZ_URL="https://theindiestone.com/forums/index.php?/forum/35-pz-updates/"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${SCRIPT_DIR}/../"

###########################################
##
## Function to compare two version numbers
##
## Return:
##   1: First version is higher
##  -1: Second version is higher
##   0: Both versions are equal
##
function versionCompare(){
  echo -1
}

# Get the laster version in dockerhub
LATEST_IMAGE_VERSION=`curl -L -s "https://registry.hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags?page_size=1024"|jq  '.results[]["name"]'|grep -iv "latest"|sort|tail -n1|sed 's/"//g'`

##########################################
##                                      ##
## Checking the latest version in Forum ##
##                                      ##
##########################################
LATEST_SERVER_VERSION=`curl "${PZ_URL}" 2>/dev/null|egrep -iv "(IWBUMS|UNSTABLE)"|grep -oPi "[0-9]{1,3}\.[0-9]{1,2} released"|sort -r|head -n1|grep -oP "[0-9]{1,3}\.[0-9]{1,2}"`
NEW_VERSION=$(versionCompare ${LATEST_IMAGE_VERSION} ${LATEST_SERVER_VERSION})

if [ $NEW_VERSION == -1 ]; then
	echo -e "\n\nA new version of the server was detected ($LATEST_SERVER_VERSION). Creating the new image...\n"
  echo "****************************************************************************"
  docker build --compress --no-cache -t ${DOCKER_IMAGE}:latest -t ${DOCKER_IMAGE}:${LATEST_SERVER_VERSION} .
  docker push ${DOCKER_IMAGE}:${LATEST_SERVER_VERSION}
  docker push ${DOCKER_IMAGE}:latest
  echo "****************************************************************************"
  echo -e "\n\n"
  exit 0
elif [ $NEW_VERSION == 0 ]; then
  echo -e "\n\nThere is no new version of the Zomboid server\n\n"
elif [ $NEW_VERSION == 1 ]; then
  echo -e "\n\nServer version is lower than latest docker version... Please, check this script because maybe is not working correctly\n\n"
else
  echo -e "\n\nThere was an unknown error.\n\n"
fi

############################################
##                                        ##
## Checking the latest version in webpage ##
##                                        ##
############################################
LATEST_SERVER_VERSION=`curl "${PZ_URL}" 2>/dev/null| grep -i "Stable Build" | head -n1 | cut -d ":" -f2 | awk '{print $1}'`

NEW_VERSION=$(versionCompare ${LATEST_IMAGE_VERSION} ${LATEST_SERVER_VERSION})

if [ $NEW_VERSION == -1 ]; then
  echo -e "\n\nA new version of the server was detected ($LATEST_SERVER_VERSION). Creating the new image...\n"
  echo "****************************************************************************"
  docker build --compress --no-cache -t ${DOCKER_IMAGE}:latest -t ${DOCKER_IMAGE}:${LATEST_SERVER_VERSION} .
  docker push ${DOCKER_IMAGE}:${LATEST_SERVER_VERSION}
  docker push ${DOCKER_IMAGE}:latest
  echo "****************************************************************************"
  echo -e "\n\n"
elif [ $NEW_VERSION == 0 ]; then
  echo -e "\n\nThere is no new version of the Zomboid server\n\n"
elif [ $NEW_VERSION == 1 ]; then
  echo -e "\n\nServer version is lower than latest docker version... Pleae, check this script because maybe is not working correctly\n\n"
else
  echo -e "\n\nThere was an unknown error.\n\n"
fi
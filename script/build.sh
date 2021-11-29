#!/bin/bash -e

###############################[SETUP]:[START]###############################
# Set the -e flag to stop running the script in case a command returns
# a non-zero exit code.
set -e

#for printing to console in color
print(){
    red=$'\e[1;31m'
    white=$'\e[0m'

    echo "$red ${1} ${white}\n"
}
###############################[SETUP]:[END]###############################




###############################[INPUT]:[START]###############################

#Move to project directory
location="/Users/ranganathaj/Desktop/Projects/Voot/InHouse_AVPlayer_PlayKit/Player-SDK-iOS/PlayerSDKiOS"
# cd $location

#Find the project name or Input Manually
PROJECT_NAME="PlayerSDKiOS";
#Configurations to build
CONFIGURATIONS=("Debug" "Release");
#Build scheme
SCHEME="PlayerSDKiOSUniversal"

#Frameworks path to be copied
DEPENDENT_FRAMEWORKS_LOCATIONS=( 
    "/Users/ranganathaj/Desktop/Projects/Voot/InHouse_AVPlayer_PlayKit/Player-SDK-iOS/PlayerSDKiOS/SDK/Frameworks/PlayerSDK-iOS/*"
    );
#Copied frameworks will be placed in 
DEPENDENT_FRAMEWORKS_LOCATION_AT_SOURCE="InHouseFrameworks/PlayerSDKiOS"
# print "hello $(pwd)";
###############################[INPUT]:[END]###############################




###############################[BUILD]:[START]###############################
# Building for each configuration from other shell script
# for config in "${CONFIGURATIONS[@]}"; do
config=$CONFIGURATION;
if [[ "$CONFIGURATION" == "" || "$CONFIGURATION" == "Default" ]]; then
    config="Debug"
fi

    print "Building ${PROJECT_NAME} ${CONFIGURATION} \n\n "
    sh build-framework.sh $PROJECT_NAME $config $SCHEME $location
# done
###############################[BUILD]:[END]###############################

# say "Exporting ${PROJECT_NAME} completed";

for path in "${DEPENDENT_FRAMEWORKS_LOCATIONS[@]}"; do
    print "Copying $path to $DEPENDENT_FRAMEWORKS_LOCATION_AT_SOURCE"
    cp -r $path $DEPENDENT_FRAMEWORKS_LOCATION_AT_SOURCE
done



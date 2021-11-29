#!/bin/bash -e
# Make sure you install `brew install xcbeautify` first for better output clarity

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


if [[ $1 == '' ]]; then
    print "Provide project name to generate the Frameworks"
    print "./framework-build.sh (target_name)"
    exit 1
fi
if [[ $2 == '' ]]; then
    print "Provide configuration to generate the Frameworks"
    print "./framework-build.sh (target_name)"
    exit 1
fi
if [[ $3 == '' ]]; then
    print "Provide Build Directory to generate the Frameworks"
    print "./framework-build.sh (target_name)"
    exit 1
fi
if [[ $4 == '' ]]; then
    print "Project location is not provided"
    print "./framework-build.sh (target_name)"
    exit 1
fi

PROJECT_NAME=$1
CONFIGURATION=$2
SCHEME=$3
location=$4

cd $location

# Invoke build-script from the build-phase

set -o pipefail && xcodebuild -workspace "${PROJECT_NAME}.xcworkspace" -scheme "${SCHEME}" -config $CONFIGURATION | xcbeautify



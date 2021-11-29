#!/bin/bash -e

# Set the -e flag to stop running the script in case a command returns
# a non-zero exit code.
set -e


red=$'\e[1;31m'
white=$'\e[0m'

workspace="../IVTNetworking.xcworkspace"
scheme="IVTNetworkingUniversal"
configuration=("Debug" "Release");

config=$1
# for config in "${configuration[@]}"; do
    echo -e "$red build-framework1 $config \n\n $white"
    # sh ./build-framework1.sh $config
    # xcodebuild -scheme $scheme -configuration $config -workspace $workspace
# done



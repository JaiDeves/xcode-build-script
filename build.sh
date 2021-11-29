#!/bin/bash -e

# Set the -e flag to stop running the script in case a command returns
# a non-zero exit code.
set -e

#for printing to console in color
print(){
    red=$'\e[1;31m'
    white=$'\e[0m'

    echo "$red ${1} ${white}\n"
}

cd ..

PROJECT_NAME="$(echo "$(ls -d *.xcodeproj/ 2>/dev/null)" | cut -d '.' -f1)";
configuration=("Debug" "Release");
BUILD_DIR="Build"
SCHEME="${PROJECT_NAME}"

for config in "${configuration[@]}"; do
    print "Building ${PROJECT_NAME} $config \n\n "
    sh script/build-framework.sh $PROJECT_NAME $config $BUILD_DIR $SCHEME
done



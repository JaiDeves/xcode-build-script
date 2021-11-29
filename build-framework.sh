#!/bin/bash -e

# Set the -e flag to stop running the script in case a command returns
# a non-zero exit code.
set -e

#for printing to console in color
print(){
    red=$'\e[1;31m'
    white=$'\e[0m'

    echo  "$red ${1} ${white}\n"
}


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
    print "Provide Build Directory to generate the Frameworks"
    print "./framework-build.sh (target_name)"
    exit 1
fi
PROJECT_NAME=$1
CONFIGURATION=$2
BUILD_DIR=$3
SCHEME=$4

# Type a script or drag a script file from your workspace to insert its path.
UNIVERSAL_OUTPUTFOLDER="SDK/Frameworks/${PROJECT_NAME}/${CONFIGURATION}"

# Go to project directory
# cd ..
# print "changing disk to $(PWD)"

if [ -d $UNIVERSAL_OUTPUTFOLDER ]; then
#Clear folder
print "Removing existing files at $UNIVERSAL_OUTPUTFOLDER"
rm -rf $UNIVERSAL_OUTPUTFOLDER;
fi

# make sure the output directory exists
mkdir  -p "${UNIVERSAL_OUTPUTFOLDER}";
print "Folder created at ${UNIVERSAL_OUTPUTFOLDER}"

BUILD_PATH_DEV="$(PWD)/Build/${CONFIGURATION}/device"
BUILD_PATH_SIM="$(PWD)/Build/${CONFIGURATION}/sim"

# Step 1. Build Device and Simulator versions
xcodebuild -workspace "${PROJECT_NAME}.xcworkspace" -scheme "${SCHEME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  CONFIGURATION_BUILD_DIR="${BUILD_PATH_DEV}" SYMROOT="${BUILD_PATH_DEV}"  -UseModernBuildSystem=YES BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" build

xcodebuild -workspace "${PROJECT_NAME}.xcworkspace" -scheme "${SCHEME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=YES CONFIGURATION_BUILD_DIR="${BUILD_PATH_SIM}" SYMROOT="${BUILD_PATH_SIM}" -UseModernBuildSystem=YES build

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
print "Copying ${BUILD_PATH_DEV}/${PROJECT_NAME}.framework to  ${UNIVERSAL_OUTPUTFOLDER}/"
cp -R "${BUILD_PATH_DEV}/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_PATH_SIM}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
print "Copying iphonesimulator build"
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_PATH_SIM}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_PATH_DEV}/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# Step 5. Copy the dSYM structure (from iphoneos build) to the universal folder
print "Copying ${BUILD_PATH_DEV}/${PROJECT_NAME}.framework.dSYM to  ${UNIVERSAL_OUTPUTFOLDER}/"
cp -R "${BUILD_PATH_DEV}/${PROJECT_NAME}.framework.dSYM" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 6. Create universal symbol file using lipo and place the combined symbol in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" "${BUILD_PATH_SIM}/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" "${BUILD_PATH_DEV}/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}"

# Step 7. Delete Framework and DSYS file from Occupant's Framework folder
# rm -rf "${PROJECT_DIR}/SDK/Frameworks/IVTNetworking/${CONFIGURATION}/${PROJECT_NAME}.framework.dSYM"
# print "Deleting ${PROJECT_DIR}/SDK/Frameworks/IVTNetworking/${CONFIGURATION}/${PROJECT_NAME}.framework.dSYM"
# rm -rf "${PROJECT_DIR}/SDK/Frameworks/IVTNetworking/${CONFIGURATION}/${PROJECT_NAME}.framework"
# print "Deleting ${PROJECT_DIR}/SDK/Frameworks/IVTNetworking/${CONFIGURATION}/${PROJECT_NAME}.framework"
print "$(PWD)"
# Step 8. Copy Framework and DSYS file from Occupant's Framework folder
print "---> Final output framework: ${UNIVERSAL_OUTPUTFOLDER}"
# cp -r "${UNIVERSAL_OUTPUTFOLDER}/" "Frameworks/${CONFIGURATION}"
#cp -r "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${PROJECT_DIR}/SDK/Frameworks/PlayerSDK-iOS/${CONFIGURATION}"
#cp -r "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework.dSYM" "${PROJECT_DIR}/SDK/Frameworks/PlayerSDK-iOS/${CONFIGURATION}"


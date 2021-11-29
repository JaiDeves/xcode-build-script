#!/bin/sh

CUR_DIR=$(eval "pwd")
if [[ $1 == '' ]]; then
	echo "Provide target to generate the Frameworks"
	echo "./framework-build.sh (target_name)"
	exit 1
fi
target=$1

cd ..

echo "Building for Device..."
xcodebuild -workspace "$target.xcworkspace" -scheme $target SYMROOT="$(PWD)/Frameworks/Device" -sdk iphoneos
DEV_LOC="$(PWD)/Frameworks/Device/Debug-iphoneos/$target.framework"
NEW_DEV_LOC="$(PWD)/Frameworks/Device/Debug-iphoneos/$target-dev.framework"

echo "Building for Simulator..."
# xcodebuild -target $target -destination 'platform=iOS Simulator,name=iPhone XR,OS=12.1' SYMROOT="Frameworks/Sim" -sdk iphonesimulator
xcodebuild -workspace "$target.xcworkspace" -scheme $target  SYMROOT="$(PWD)/Frameworks/Sim" -sdk iphonesimulator 
SIM_LOC="$(PWD)/Frameworks/Sim/Debug-iphonesimulator/$target.framework"
NEW_SIM_LOC="$(PWD)/Frameworks/Sim/Debug-iphonesimulator/$target-sim.framework"

echo "Renaming $DEV_LOC to $NEW_DEV_LOC"
mv -v -f $DEV_LOC $NEW_DEV_LOC

echo "Renaming $SIM_LOC to $NEW_SIM_LOC"
mv -v -f $SIM_LOC $NEW_SIM_LOC

echo "Moving $NEW_DEV_LOC to $CUR_DIR/Frameworks"
mv -f $NEW_DEV_LOC "$CUR_DIR/Frameworks"

echo "Moving $NEW_SIM_LOC to $CUR_DIR/Frameworks"
mv -f $NEW_SIM_LOC "$CUR_DIR/Frameworks"

echo "Removing Device and Sim Directories"
# rm -r "$CUR_DIR/Frameworks/Device"
# rm -r "$CUR_DIR/Frameworks/Sim"

echo "Backing up device framework"
cp -r "$CUR_DIR/Frameworks/$target-dev.framework" "$CUR_DIR/Frameworks/$target-device.framework"

echo "Creating FAT framework"
eval "lipo -create $CUR_DIR/Frameworks/$target-sim.framework/$target $CUR_DIR/Frameworks/$target-dev.framework/$target -output $CUR_DIR/Frameworks/$target"

echo "Copying swift module file"
mv -f "$CUR_DIR/Frameworks/$target" "$CUR_DIR/Frameworks/$target-dev.framework/"

echo "Appending iOS Simulator in Info.plist"
plutil -insert CFBundleSupportedPlatforms.1 -string iPhoneSimulator "$CUR_DIR/Frameworks/$target-dev.framework/Info.plist"

echo "copying simulator swiftmodule files to fat framework"
cp -fr "$CUR_DIR/Frameworks/$target-sim.framework/Modules/$target.swiftmodule/x86_64.swiftdoc" "$CUR_DIR/Frameworks/$target-dev.framework/Modules/$target.swiftmodule/"
cp -fr "$CUR_DIR/Frameworks/$target-sim.framework/Modules/$target.swiftmodule/x86_64.swiftmodule" "$CUR_DIR/Frameworks/$target-dev.framework/Modules/$target.swiftmodule/"

echo "renaming fat framework to actual framework name"
mv -f "$CUR_DIR/Frameworks/$target-dev.framework" "$CUR_DIR/Frameworks/$target.framework"

exit 0
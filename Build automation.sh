#!/bin/bash
# Make sure you install `brew install xcbeautify` first for better output clarity
# Please Change these variables according to the build configuration you require

readonly targetSDK="iphoneos"                                               # targetSDK : e.g. iphoneos
readonly targetSDKSim="iphonesimulator"
readonly buildConfig="Debug"                                                # buildConfig : Debug, Release or Distribution
readonly workspaceFile="ModularApp/ModularApp.xcworkspace"                  # yourWorkspaceFile : path and filename of workspace file, e.g. path/ModularApp.xcworkspace * (points to ./path/ModularApp.xcworkspace)*
readonly NameOfCertificateIdentity="Abhinav Kumar"                           # NameOfCertificateIdentity : e.g. iPhone Developer: My Name (738d039880d)
readonly ProvisioningProfileName="CDNA Technologies"                        # ProvisioningProfileName: e.g. CDNA Technologies Profile
readonly keyChainName="/Users/abhinavkumar/Library/Keychains/login.keychain" # keyChainName: points to your keychain that can open development certificate, e.g. /Users/piyushmehta/Library/Keychains/login.keychain

# If required use this tag
# readonly if_required=CODE_SIGN_IDENTITY=$NameOfCertificateIdentity PROVISIONING_PROFILE=$ProvisioningProfileName OTHER_CODE_SIGN_FLAGS=$keyChainName
cleanup() {
    cd Build
    rm -rf *
    cd ../
    cd BuildSim
    rm -rf *
    cd ../
    cd BuildUni
    rm -rf *
    cd ../
}
# Works only for Modular App
build_app() {
    set -o pipefail && xcodebuild -workspace $workspaceFile -scheme ModularApp -sdk $targetSDK -configuration $buildConfig | xcbeautify
}

# Builds all individual categories including adapters
build_categories() {
    declare -a categories=("BillPayments" "Bus" "Cabs" "CreditScore" "Donations" "Flights" "GiftCard" "GoldSubscription" "Hotel" "NucleiAnalytics" "Recharge" "PaymentAdapter" "CoreAdapter")
    for i in "${categories[@]}"; do
        echo "\033[1;36m Building: $i \033[0m"
        set -o pipefail && xcodebuild -workspace $workspaceFile -scheme "$i" -sdk $targetSDK -configuration $buildConfig | xcbeautify
    done
}

generate_universal() {
    cp -r Build/* BuildUni/
    declare -a categories=("Core" "BillPayments" "Bus" "Cabs" "CreditScore" "Donations" "Flights" "GiftCard" "GoldSubscription" "Hotel" "NucleiAnalytics" "Recharge" "PaymentAdapter" "CoreAdapter")

    for i in "${categories[@]}"; do
        cp -r "BuildSim/${i}.framework/Modules/${i}.swiftmodule/." "BuildUni/${i}.framework/Modules/${i}.swiftmodule"
    done

    for i in "${categories[@]}"; do
        lipo -create "BuildSim/${i}.framework/${i}" "Build/${i}.framework/${i}" -output "BuildUni/${i}.framework/${i}"
    done
}

update_header_universal() {
    declare -a categories=("Core" "BillPayments" "Bus" "Cabs" "CreditScore" "Donations" "Flights" "GiftCard" "GoldSubscription" "Hotel" "NucleiAnalytics" "Recharge" "PaymentAdapter" "CoreAdapter")
    for i in "${categories[@]}"; do
        sed -i '.bak' '1d' "BuildUni/${i}.framework/Headers/${i}-Swift.h"
        touch intermediate.txt
        echo "#if TARGET_OS_SIMULATOR" >> intermediate.txt
        cat "BuildSim/${i}.framework/Headers/${i}-Swift.h" >> intermediate.txt
        cat "BuildUni/${i}.framework/Headers/${i}-Swift.h" >> intermediate.txt
        rm "BuildUni/${i}.framework/Headers/${i}-Swift.h"
        mv intermediate.txt "BuildUni/${i}.framework/Headers/${i}-Swift.h"
        rm "BuildUni/${i}.framework/Headers/${i}-Swift.h.bak"
    done
}

# Moves all the frameworks to /Build folder
move_builds() {
    current_dir="$(pwd)"
    echo $current_dir
    cd /Users/"$(whoami)"/Library/Developer/Xcode/DerivedData/ModularApp*/Build/Products/$buildConfig-$targetSDK
    cp -r *.framework $current_dir/Build
    echo "moved builds to $current_dir/Build successfully"
    cd /Users/"$(whoami)"/Library/Developer/Xcode/DerivedData/ModularApp*/Build/Products/$buildConfig-$targetSDKSim
    cp -r *.framework $current_dir/BuildSim
    echo "moved builds to $current_dir/BuildSim successfully"
    cd $current_dir
}

main() {
    # Clean Up
    cleanup

    # This build should fail for the first time (ModularApp)
    echo "\033[1;36m Modular App \033[0m"
    build_app

    # CORE
    echo "\033[1;36m Core \033[0m"
    set -o pipefail && xcodebuild -workspace $workspaceFile -scheme Core -sdk $targetSDK -configuration $buildConfig | xcbeautify

    #Categories
    echo "\033[1;36m Categories \033[0m"
    build_categories

    # Final
    echo "\033[1;36m Finishing up stuff... \033[0m"
    build_app

    # Move Builds
    move_builds

    # Generate Universal
    generate_universal

    # update header of universal frameworks
    update_header_universal
}

# Invoke
time main

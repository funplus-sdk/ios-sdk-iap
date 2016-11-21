#!/usr/bin/env bash

# go to project root.
if [[ $(pwd) == *Scripts ]]; then
    cd ..
fi

ver=$(grep "VERSION = " FunPlusAppleIAP/FunPlusAppleIAP.swift | sed "s/\"//g" | sed "s/public static let VERSION = //g")
out=$(echo Release/funplus-ios-iap-sdk-$ver | tr -d ' ')

echo SDK version: $ver
echo Output directory: $out

# check output directory.
if [ -d $out ]; then
    read -p 'Directory exists. This action will erase the existing directory, are you sure? [yN] ' yn
    if [[ $yn != 'y' && $yn != 'Y' ]]; then
        echo exit
        exit
    else
        rm -rf $out
    fi
fi

echo

# prepare output directory.
mkdir $out

# copy docs
cp {README,CHANGELOG}.md $out/

# build device SDK
xcodebuild -target FunPlusAppleIAP -configuration Release -sdk iphoneos

# build simulator SDK
xcodebuild -target FunPlusAppleIAP -configuration Release -sdk iphonesimulator

build_dir=Build/Products
device_framework=$build_dir/Release-iphoneos/FunPlusAppleIAP.framework
simulator_framework=$build_dir/Release-iphonesimulator/FunPlusAppleIAP.framework
fat_framework=$build_dir/FunPlusAppleIAP.framework

lipo -create -output $build_dir/FunPlusAppleIAP $device_framework/FunPlusAppleIAP $simulator_framework/FunPlusAppleIAP
cp -R $device_framework $fat_framework
mv $build_dir/FunPlusAppleIAP $fat_framework/FunPlusAppleIAP
echo $ver > $fat_framework/VERSION
cp -R $fat_framework $out/FunPlusAppleIAP.framework

#!/usr/bin/env bash

# go to project root.
if [[ $(pwd) == *Scripts ]]; then
    cd ..
fi

ver=$(grep "VERSION = " Source/FunPlusAppleIAP.swift | sed "s/\"//g" | sed "s/public static let VERSION = //g" | tr -d ' ')
framework=FunPlusAppleIAP.framework

src=Release/funplus-ios-iap-sdk-$ver/$framework
target_dir=../../unity/sdk-iap/Assets/FunPlusAppleIAP/Plugins/iOS

if [ -d $target_dir/FunPlusAppleIAP.framework ]; then
    rm -rf $target_dir/FunPlusAppleIAP.framework*
fi

dst=$target_dir/$framework

cp -R $src $dst

echo Copied $src to $dst

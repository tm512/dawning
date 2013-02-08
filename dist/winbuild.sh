#!/bin/sh

rev=$(git rev-parse --short HEAD)

unzip love-0.8.0-win-x86.zip
mv love-0.8.0-win-x86 dawning-win32-$rev

cd dawning-win32-$rev
mv love.exe dawning.exe
cp ../../README.txt .

cat ../../dawning.love >> dawning.exe

cd ../
zip dawning-win32-${rev}.zip dawning-win32-$rev/*
rm -r dawning-win32-$rev

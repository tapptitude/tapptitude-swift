#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p ~/"Library/Developer/Xcode/Templates/Application/"
mkdir -p ~/"Library/Developer/Xcode/Templates/File Templates/"

echo "$DIR/Application/" "-->" ~/"Library/Developer/Xcode/Templates/Application/"
cp -R  "$DIR/Application/" ~/"Library/Developer/Xcode/Templates/Application/"

echo "$DIR/File Templates/" "-->" ~/"Library/Developer/Xcode/Templates/File Templates/"
cp -R "$DIR/File Templates/" ~/"Library/Developer/Xcode/Templates/File Templates/"

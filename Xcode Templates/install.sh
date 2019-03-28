#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p ~/"Library/Developer/Xcode/Templates/File Templates/"


echo "$DIR/File Templates/" "-->" ~/"Library/Developer/Xcode/Templates/File Templates/"
cp -R "$DIR/File Templates/" ~/"Library/Developer/Xcode/Templates/File Templates/"

#!/bin/bash

PREFIX=$1
DST_SRC=$2
BUILD_SRC=$3

echo "Installation prefix size after /src transfer:"
du -sk "$PREFIX"
echo "Copied sources size:"
du -sk "$DST_SRC"
echo "Original source size in build tree:"
du -sk "$BUILD_SRC"

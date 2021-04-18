#!/usr/bin/env zsh
SCRIPTPATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
cd $SCRIPTPATH

mkdir -p build; cd build

# install directly to virtual env to make life simplier
# use python3 as builder cuz I whant python3 bindings. Don't know
#   if it actually changes anything
# only specified modules and their dependencies are built. 
# This saves A LOT of time actually.
cmake -GNinja \
    -D CMAKE_INSTALL_PREFIX="$HOME/.virtualenvs/3D-reconstruction" \
    -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
    -D CMAKE_BUILD_TYPE='Release' \
    -D OPENCV_ENABLE_NONFREE='YES' \
    -D OPENCV_EXTRA_MODULES_PATH='../opencv_contrib/modules' \
    -D BUILD_LIST=python3,videoio,highgui,xfeatures2d \
    "../opencv"
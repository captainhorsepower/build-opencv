#!/usr/bin/env zsh


mkdir -p build; cd build

# install directly to virtual env to make life simplier
cmake -GNinja \
    -D CMAKE_INSTALL_PREFIX="$HOME/.virtualenvs/3D-reconstruction" \
    -D CMAKE_BUILD_TYPE='Release' \
    -D OPENCV_ENABLE_NONFREE='ON' \
    "../opencv"
    # -D OPENCV_EXTRA_MODULES_PATH='../extra-modules' \
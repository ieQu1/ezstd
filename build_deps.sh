#!/usr/bin/env bash

ROOT=$(pwd)
DEPS_LOCATION=_build/deps
OS=$(uname -s)
KERNEL=$(echo $(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 | awk '{print $1;}') | awk '{print $1;}')
CPUS=`getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu`

# https://github.com/facebook/zstd.git

ZSTD_DESTINATION=zstd
ZSTD_REPO=https://github.com/facebook/zstd.git
ZSTD_BRANCH=master
ZSTD_TAG=v1.5.2 # Tag is just for the information purpose only, we checkout the commit instead
ZSTD_COMMIT="e47e674cd09583ff0503f0f6defd6d23d8b718d3"
ZSTD_SUCCESS=lib/libzstd.a

fail_check()
{
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
        exit 1
    fi
}

CheckoutLib()
{
    if [ -d "${DEPS_LOCATION}/${ZSTD_DESTINATION}" ]; then
        echo "$4 fork already exist. delete $DEPS_LOCATION/$4 for a fresh checkout ..."
    else
        #repo rev branch destination
        mkdir -p $DEPS_LOCATION
        pushd $DEPS_LOCATION

        if [ ! -d "$4" ]; then
            fail_check git clone "${ZSTD_REPO}" "${ZSTD_DESTINATION}"
        fi

        pushd "${ZSTD_DESTINATION}"
        fail_check git checkout --detach "${ZSTD_COMMIT}"
        BuildLibrary $4
        popd
        popd


    fi
}

BuildLibrary()
{
    case $OS in
        Linux)
            export CFLAGS="-fPIC"
            export CXXFLAGS="-fPIC"
            ;;
        *)
            ;;
    esac

    fail_check make -j $CPUS
    rm -rf lib/*.so
    rm -rf lib/*.so.*
    rm -rf lib/*.dylib
}

CheckoutLib

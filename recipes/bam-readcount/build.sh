#!/bin/bash -euo

set -x

wget https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-cmake.tar.gz

mv boost-1.85.0-cmake.tar.gz vendor/boost-1.55-bamrc.tar.gz

mkdir -p "${PREFIX}/bin"

# Needed for building utils dependency
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -lz -lbz2"
    export MACOSX_DEPLOYMENT_TARGET=10.13
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
    # export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir -p build
pushd build
cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

make clean
make CXX="${CXX} ${LDFLAGS}" CC="${CC}" CXXFLAGS="${CXXFLAGS}"

chmod 755 bin/bam-readcount
cp -f bin/bam-readcount "${PREFIX}/bin"
popd

#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
python_bin=${PYTHON_BIN:-/opt/homebrew/Caskroom/miniconda/base/envs/env/bin/python}
build_dir="$project_dir/build/macos-arm64"
fftw_source_dir="$build_dir/fftw-source"
fftw_prefix="$build_dir/fftw-prefix"
fftw_build_dir="$fftw_source_dir/build"

if [ "$(uname -m)" != "arm64" ]; then
    echo "This build script requires an Apple Silicon (arm64) Mac." >&2
    exit 1
fi

if [ ! -x "$python_bin" ]; then
    echo "Python interpreter not found: $python_bin" >&2
    exit 1
fi

mkdir -p "$fftw_source_dir" "$fftw_prefix"
if [ ! -d "$fftw_source_dir/fftw-2.1.5" ]; then
    tar -xzf "$project_dir/ext_lib/fftw-2.1.5-mac.tar.gz" -C "$fftw_source_dir"
fi
mkdir -p "$fftw_build_dir"

if [ ! -f "$fftw_build_dir/Makefile" ]; then
    (
        cd "$fftw_build_dir"
        ../fftw-2.1.5/configure \
            --enable-float \
            --enable-static \
            --disable-shared \
            --disable-fortran \
            --disable-dependency-tracking \
            CC="cc -arch arm64" \
            --prefix="$fftw_prefix"
    )
fi

make -C "$fftw_build_dir" -j8 \
    CFLAGS="-O3 -fPIC -arch arm64 -mmacosx-version-min=11.0"
make -C "$fftw_build_dir" install \
    CFLAGS="-O3 -fPIC -arch arm64 -mmacosx-version-min=11.0"

make -C "$project_dir/cpp/gcc" -f Makefile_mac clean_obj
make -C "$project_dir/cpp/gcc" -f Makefile_mac -j8 lib \
    FFTW_DIR="$fftw_prefix" \
    PRG_LIB=libradia.a \
    LIBCFLAGS="-arch arm64 -mmacosx-version-min=11.0 -O3 -fPIC \
        -I$project_dir/cpp/src/core \
        -I$project_dir/cpp/src/lib \
        -I$project_dir/cpp/src/ext/auxparse \
        -I$project_dir/cpp/src/ext/genmath \
        -I$project_dir/cpp/src/ext/triangle \
        -D__GCC__ -DFFTW_ENABLE_FLOAT -DNO_TIMER \
        -DANSI_DECLARATORS -DTRILIBRARY -D_GM_WITHOUT_BASE \
        -DALPHA__LIB__ -Wno-narrowing"

RADIA_FFTW_PREFIX="$fftw_prefix" \
    "$python_bin" -m pip install --no-build-isolation --no-deps \
    --force-reinstall "$project_dir/cpp/py"

"$python_bin" -c \
    'import platform, radia; print(f"Radia {radia.UtiVer()} installed for {platform.machine()} at {radia.__file__}")'

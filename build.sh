#!/bin/sh

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Points to a Chromium checkout.
SRCDIR=${SRCDIR:-~/chromium/src}

# Cleanup.
rm -rf repo/
mkdir repo/

# gn root.
cp ${SRCDIR}/.gn repo/

cat << EOF > repo/BUILD.gn
import("//build/config/compiler/compiler.gni")
import("//build/config/features.gni")
import("//build/config/sanitizers/sanitizers.gni")

group("gn_all") {
  testonly = true
  deps = [
    "//tools/gn:gn",
    "//tools/gn:gn_unittests",
  ]
}

declare_args() {
  v8_extra_library_files = []
  v8_experimental_extra_library_files = []
  v8_enable_inspector = true
  v8_enable_gdbjit = false
  v8_imminent_deprecation_warnings = false
}
EOF

# base
cp -r ${SRCDIR}/base repo/

# build subset
mkdir -p repo/build/
cp ${SRCDIR}/build/buildflag.h repo/build/
cp ${SRCDIR}/build/build_config.h repo/build/
cp ${SRCDIR}/build/build_config.h repo/build/
cp ${SRCDIR}/build/buildflag_header.gni repo/build/
cp ${SRCDIR}/build/dotfile_settings.gni repo/build/
cp ${SRCDIR}/build/nocompile.gni repo/build/
cp ${SRCDIR}/build/precompile.h repo/build/
cp ${SRCDIR}/build/write_buildflag_header.py repo/build/
cp ${SRCDIR}/build/write_build_date_header.py repo/build/

cp -r ${SRCDIR}/build/config repo/build/
cp -r ${SRCDIR}/build/toolchain repo/build/

# build platforms
cp -r ${SRCDIR}/build/linux repo/build/
cp -r ${SRCDIR}/build/mac repo/build/
cp -r ${SRCDIR}/build/win repo/build/

# build/secondary subset
mkdir -p repo/build/secondary/
cp -r ${SRCDIR}/build/secondary/testing repo/build/secondary/

# build/util subset
mkdir -p repo/build/util/
cp ${SRCDIR}/build/util/LASTCHANGE repo/build/util/


# build_overrides
cp -r ${SRCDIR}/build_overrides repo/

# testing subset
mkdir -p repo/testing/
cp -r ${SRCDIR}/testing/gmock repo/testing/
cp -r ${SRCDIR}/testing/gtest repo/testing/
cp -r ${SRCDIR}/testing/perf repo/testing/
cp -r ${SRCDIR}/testing/*.cc repo/testing/
cp -r ${SRCDIR}/testing/*.h repo/testing/
cp -r ${SRCDIR}/testing/*.mm repo/testing/
cp ${SRCDIR}/testing/test.gni repo/testing/

# testing/libfuzzer subset
mkdir -p repo/testing/libfuzzer
cp ${SRCDIR}/testing/libfuzzer/fuzzer_test.gni repo/testing/libfuzzer/

# third_party subset
mkdir -p repo/third_party/
cp -r ${SRCDIR}/third_party/apple_apsl repo/third_party/
cp -r ${SRCDIR}/third_party/ced repo/third_party/
cp -r ${SRCDIR}/third_party/icu repo/third_party/
cp -r ${SRCDIR}/third_party/libxml repo/third_party/
cp -r ${SRCDIR}/third_party/modp_b64 repo/third_party/
cp -r ${SRCDIR}/third_party/zlib repo/third_party/


# gn
mkdir -p repo/tools/
cp -r ${SRCDIR}/tools/gn repo/tools/

# tools/clang
cp -r ${SRCDIR}/tools/clang repo/tools

# clang
cp -r ${SRCDIR}/third_party/llvm-build repo/third_party/

# NOTE: The hack below doesn't work because the GN build
#       configuration includes warnings that haven't been
#       upstreamed / are only available in very new clang versions.
# mkdir -p repo/third_party/llvm-build/Release+Asserts/bin/
# ln -s $(which clang) repo/third_party/llvm-build/Release+Asserts/bin/clang

# These files aren't necessary to get the repo to build.
cp ${SRCDIR}/LICENSE repo/

cat << EOF > repo/.gitignore
*~
.*.sw?
.DS_Store
/out*
/out_bootstrap
EOF

# Bootstrap gn
cd repo
tools/gn/bootstrap/bootstrap.py --verbose --no-clean --no-rebuild

# Build gn using the bootstrapped version.
out_bootstrap/gn gen out/Release --args=is_debug=false \
    --args=clang_use_chrome_plugins=false
ninja -C out/Release gn gn_unittests

# Remove the bootstrapped version.
rm -rf out_bootstrap

# Run tests.
out/Release/gn_unittests

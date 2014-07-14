#!/bin/bash -x
# source: http://forum.odroid.com/viewtopic.php?f=52&t=2973


. utils.sh


function build_libcec() {
  local version="${1:-"2.1.3"}"

  install_dependencies
  clone_and_build "${version}"
  test_libcec
}


function install_dependencies() {
  for package in "build-essential" \
                 "libudev-dev" \
                 "automake" \
                 "libtool" \
                 "pkg-config" \
                 "liblockdev1" \
                 "liblockdev1-dev" \
                 "checkinstall"
  do
    install_package "${package}"
  done
}


function clone_and_build() {
  local version="${1}"

  git_clone "https://github.com/mdrjr/libcec.git" # "libcec-${version}" ## requires master's commits to properly work
  cd "${clone}"

  ./bootstrap
  ./configure --enable-exynos
  make -j5

  checkinstall -y --pkgversion="${version}"
  dpkg -i "libcec_${version}-1_armhf.deb"
  ldconfig

  cd -
}


function test_libcec() {
  if cec-client | head -1 > /dev/null
  then
    success
  else
    failure
  fi
}

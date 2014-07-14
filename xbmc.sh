#!/bin/bash
# source: http://forum.odroid.com/viewtopic.php?f=61&t=4073&p=45188
#         http://forum.odroid.com/viewtopic.php?f=61&t=2589&start=320#p39352

. utils.sh
. libcec.sh
. hybris.sh

function build_xbmc() {
  install_dependencies
  clone_and_build
}

function install_dependencies() {
  # from xbmc docs/README.ubuntu
  for package in "automake" \
                 "bison" \
                 "build-essential" \
                 "ccache" \
                 "cmake" \
                 "curl" \
                 "cvs" \
                 "default-jre" \
                 "fp-compiler" \
                 "gawk" \
                 "gdc" \
                 "gettext" \
                 "git-core" \
                 "gperf" \
                 "libasound2-dev" \
                 "libass-dev" \
                 "libboost-dev" \
                 "libboost-thread-dev" \
                 "libbz2-dev" \
                 "libcap-dev" \
                 "libcdio-dev" \
                 "libcurl3" \
                 "libcurl4-gnutls-dev" \
                 "libdbus-1-dev" \
                 "libenca-dev" \
                 "libflac-dev" \
                 "libfontconfig-dev" \
                 "libfreetype6-dev" \
                 "libfribidi-dev" \
                 "libglew-dev" \
                 "libiso9660-dev" \
                 "libjasper-dev" \
                 "libjpeg-dev" \
                 "liblzo2-dev" \
                 "libmad0-dev" \
                 "libmicrohttpd-dev" \
                 "libmodplug-dev" \
                 "libmpeg2-4-dev" \
                 "libmpeg3-dev" \
                 "libmysqlclient-dev" \
                 "libnfs-dev" \
                 "libogg-dev" \
                 "libpcre3-dev" \
                 "libplist-dev" \
                 "libpng-dev" \
                 "libpulse-dev" \
                 "libsamplerate-dev" \
                 "libsdl-dev" \
                 "libsdl-gfx1.2-dev" \
                 "libsdl-image1.2-dev" \
                 "libsdl-mixer1.2-dev" \
                 "libsmbclient-dev" \
                 "libsqlite3-dev" \
                 "libssh-dev" \
                 "libssl-dev" \
                 "libtiff-dev" \
                 "libtinyxml-dev" \
                 "libtool" \
                 "libudev-dev" \
                 "libusb-dev" \
                 "libvdpau-dev" \
                 "libvorbisenc2" \
                 "libxml2-dev" \
                 "libxmu-dev" \
                 "libxrandr-dev" \
                 "libxrender-dev" \
                 "libxslt1-dev" \
                 "libxt-dev" \
                 "libyajl-dev" \
                 "mesa-utils" \
                 "nasm" \
                 "pmount" \
                 "python-dev" \
                 "python-imaging" \
                 "python-sqlite" \
                 "swig" \
                 "unzip" \
                 "yasm" \
                 "zip" \
                 "zlib1g-dev" \
                 "autopoint" \
                 "libltdl-dev" \
                 "libtag1-dev"
  do
    install_package "${package}"
  done

  if ! test_libcec
  then
    build_libcec
  fi

  #if ! test_libhybris
  #then
  #  build_libhybris
  #fi
}


function clone_and_build() {
  local hybris_include_path="${1:-"/usr/local/include/hybris"}"

  if [ ! -d "${hybris_include_path}" ]
  then
    failure "invalid hybris include path '${$hybris_include_path}'"
  fi

  git_clone "https://github.com/Owersun/xbmc.git" "Gotham"
  cd "${clone}"

  ./bootstrap
  FFMPEG_CFLAGS="-mfloat-abi=hard -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -mcpu=cortex-a15 -mtune=cortex-a15 -O3 -pipe -fstack-protector" \
  CFLAGS="-mfloat-abi=hard -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -mcpu=cortex-a15 -mtune=cortex-a15 -O3 -pipe -fstack-protector -DTARGET_HYBRIS=1 -I${hybris_include_path}" \
  CXXFLAGS="-mfloat-abi=hard -mfpu=neon -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -mcpu=cortex-a15 -mtune=cortex-a15 -O3 -pipe -fstack-protector -DTARGET_HYBRIS=1 -I${hybris_include_path}" \
  ./configure --enable-codec=mfc \
              --enable-alsa \
              --disable-pulse \
              --disable-airtunes \
              --disable-airplay \
              --enable-libcec \
              --enable-neon \
              --disable-debug \
              --enable-optimizations \
              --enable-ccache \
              --disable-gl \
              --enable-gles \
              --disable-xrandr \
              --disable-x11 \
              --enable-non-free \
              --disable-vdpau \
              --disable-vaapi \
              --disable-crystalhd \
              --disable-openmax \
              --disable-rsxs \
              --disable-projectm \
              --disable-fishbmc \
              --disable-nfs \
              --disable-afpclient \
              --disable-dvdcss \
              --disable-optical-drive \
              --disable-libbluray \
              --enable-texturepacker \
              --enable-joystick \
              --with-platform=odroid-xu \
              --with-cpu=cortex-a15 \
              --prefix=/usr

  make -j5
  make install 

  cd -
}

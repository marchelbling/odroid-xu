#!/bin/bash
# source: http://forum.odroid.com/viewtopic.php?f=62&t=2176

. utils.sh

function build_libhybris() {
  prefix="${hybris_prefix:-"/usr/local/"}"
  local image="${1}"
  sync_from_android "${1}"

  clone_and_build
  update_startup_script
  test_libhybris
  cd -
}


function start_android_services() {
  /vendor/bin/pvrsrvctl --start --no-module || true
  /system/bin/servicemanager &
  /system/bin/mediaserver &
}
export -f start_android_services


function stop_android_services() {
  pkill pvrsrvctl
  pkill servicemanager
  pkill mediaserver
}
export -f stop_android_services

function stop_display_services() {
  service lightdm stop
  service exynos5-hwcomposer stop
}
export -f stop_display_services


function sync_from_android() {
  local image="${1}"
  local mnt_path="${2:-"/mnt/reference_image"}"
  if [ "${image}" ]
  then
    if [ ! -e "${image}" ]
    then
      failure "image file '${image}' is missing."
    fi

    mount_reference_image "${image}" "${mnt_path}"
    sync_from_image "${mnt_path}"
    umount "${mnt_path}"
  fi
}


function mount_reference_image() {
  local image="${1}"
  local mnt_path="${2}"
  if [ ! -d "${mnt_path}" ]
  then
    mkdir -p "${mnt_path}"
  fi
  # should read sector size dynamically using `fdisk -l`
  local sector_size=512
  # find linux partition start offset
  local linux="$( fdisk -l "${image}" | grep -i "linux" )"
  local offset="$( echo $linux | cut -d' ' -f2 )"

  mount "${image}" "${mnt_path}" -o offset=$(($offset*$sector_size))
}


function sync_from_image() {
  local mnt_path="${1}"

  rsync -azvh "${mnt_path}"/system /
  ln -s /system/vendor /vendor

  rsync -azvh "${mnt_path}"/usr/include/android /usr/include/
}


function update_startup_script() {
  local src="${1:-"/etc/rc.local"}"
  local last_line="$( tail -1 "${src}" )"
  local tmp="$( tempfile )"

  local lines="$( wc -l "${src}" | cut -d' ' -f1 )"
  head -n $((${lines} - 1)) "${src}" > "${tmp}"

  echo """
rm -rf /dev/log
rm -rf /dev/graphics
mkdir /dev/log
mkdir /dev/graphics
ln -s /dev/log_events /dev/log/events
ln -s /dev/log_main /dev/log/main
ln -s /dev/log_system /dev/log/system
ln -s /dev/log_radio /dev/log/radio
ln -s /dev/fb0 /dev/graphics/fb0

/vendor/bin/pvrsrvctl --start --no-module || true
/system/bin/servicemanager &
/system/bin/mediaserver &
""" >> "${tmp}"

  echo "${last_line}" >> "${tmp}"
  mv "${src}" "${src}.old"
  mv "${tmp}" "${src}"
  chmod +x "${src}"
}


function clone_and_build() {
  git_clone "https://github.com/vamanea/hybris.git"
  cd "${clone}/hybris"

  ./autogen.sh --with-default-egl-platform=hwcomposer --prefix="${prefix}"
  make -j5
  make install

  cd -
}


function test_libhybris() {
  stop_android_services
  stop_display_services
  start_android_services
  assert_process "servicemanager"
  assert_process "mediaserver"

  # TODO: find a way to stop test_hwcomposer and get result
  LD_LIBRARY_PATH="${prefix}/lib:$LD_LIBRARY_PATH" test_hwcomposer
}

#!/bin/bash

function success() {
  local msg="${1:"${FUNCNAME[1]}"}"  # caller name
  echo "${msg} successful"
  return 0
}
export -f success


function failure() {
  local msg="${1:"${FUNCNAME[1]}"}"  # caller name
  echo "${msg} failure"
  return 1
}
export -f failure


function decompress() {
    local archive="$1"
    local output_dir="$2:-"$( pwd )""
    7z x "$archive" -o"$output_dir"
}
export -f decompress


function get_extension(){
    local fullname="${1}"
    local filename="${fullname##*/}"
    local extension="${filename##*.}"
    echo "${extension}" | tr '[A-Z]' '[a-z]'
}
export -f get_extension


function strip_extension(){
    local name="${1}"
    echo "${name%.*}"
}
export -f strip_extension


function install_package() {
    local package="${1}"
    if [ "${package}" ]
    then
        apt-get install -y "${package}"
    fi
}
export -f install_package


function git_clone() {
  local remote="${1}"
  local branch_or_tag="${2}"
  local clone_dir="${3:-${CLONE_DIR:-"/root/builds/"}}"
  local current="$( pwd )"

  # human repo name
  local repo="$( strip_extension $( basename "${remote}" ) )"
  # clone absolute path
  clone="${clone_dir}/${repo}"

  git clone --recursive --branch "${branch_or_tag}" "${remote}" "${clone}"
}
export -f git_clone


function odroid_utility() {
  # odroid-utility script automatically updates itself so no need to track git repo
  if ! -e /usr/local/bin/odroid-utility.sh
  then
    wget -O /usr/local/bin/odroid-utility.sh \
            https://raw.githubusercontent.com/mdrjr/odroid-utility/master/odroid-utility.sh
    chmod +x /usr/local/bin/odroid-utility.sh
  fi
  odroid-utility.sh
}

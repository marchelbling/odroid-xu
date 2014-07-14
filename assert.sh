#!/bin/bash


function success() {
  local msg="${1:-"${FUNCNAME[1]}"}"  # caller name
  echo "success: ${msg}"
  return 0
}
export -f success


function failure() {
  local msg="${1:-"${FUNCNAME[1]}"}"  # caller name
  echo "failure: ${msg}"
  exit 1
}
export -f failure


assert_process() {
  local process="${1}"
  pgrep "${process}" &> /dev/null || failure "process '${process}' not running"
}
export -f assert_process

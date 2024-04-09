#!/usr/bin/env bash
# put me in /home/pi/prusa-connect.sh
# dependencies:
# rpicam-still (to use your Raspberry Pi Camera Module)
# curl (to send images via HTTP to prusa-connect)
# bash (to run this script)
# install with:
# sudo apt install rpicam-apps-lite curl bash

set -Eeu
set -o pipefail
shopt -s extdebug

FINGERPRINT="your-printer-fingerprint"
TOKEN="your-prusa-connect-webcam-token"
# PRINTER_UUID="abcdef01-2345-6789-abcd-ef0123456"

# shellcheck disable=SC2154
trap 'declare rc=$?;
      >&2 echo "Unexpected error (exit-code $rc) executing $BASH_COMMAND at ${BASH_SOURCE[0]} line $LINENO";
      exit $rc' ERR

main () {

  while true
  do
    if rpicam-still \
      --width 2304 --height 1296 \
      -v 0 \
      -t 1000 \
      --nopreview \
      -o - \
    | curl  https://webcam.connect.prusa3d.com/c/snapshot  \
      -X PUT \
      -L --no-progress-meter --fail-with-body \
      -H "Content-Type: image/jpg" \
      -H "Fingerprint: $FINGERPRINT" \
      -H "Token: $TOKEN" \
      --data-binary @-
    then
      echo
      printf "."
    else
      echo
      echo "oops, failed"
      sleep 50
    fi
    sleep 10
  done
}

main "$@"

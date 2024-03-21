#!/bin/bash

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"


cp -v opt/retroarch/cores/tic80_libretro.so /opt/retroarch/cores/tic80_libretro.so

clear
echo
echo
echo "TIC-80 CORE INSTALLED SUCCESSFULLY!"

sleep 3

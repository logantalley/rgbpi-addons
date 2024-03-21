#!/bin/bash

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

[ -f /opt/retroarch/cores/retro8_libretro.so ] && \
    mv -vn /opt/retroarch/cores/retro8_libretro.so /opt/retroarch/cores/retro8_libretro.so.bak

cp -v opt/retroarch/cores/retro8_libretro.so /opt/retroarch/cores/retro8_libretro.so

clear
echo
echo
echo "CORE UPDATED SUCCESSFULLY!"

sleep 3

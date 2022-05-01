#!/bin/bash -ex

[[ -z ${1+x} ]] && DIR_IN_PATH="$HOME/bin" || DIR_IN_PATH="$1"

FILE_TO_COPY="bindfs-to-home.sh"

cp -iuv "${FILE_TO_COPY}" "${DIR_IN_PATH}/"

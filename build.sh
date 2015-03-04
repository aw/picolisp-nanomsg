#!/bin/sh
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
# MIT License

set -u
set -e

git submodule init
git submodule update

cd vendor/nanomsg
  ./autogen.sh
  ./configure --enable-shared
  make
cd -

cd lib
  rm -f libnanomsg.so
  ln -s ../vendor/nanomsg/.libs/libnanomsg.so libnanomsg.so
cd -

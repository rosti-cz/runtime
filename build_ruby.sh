#!/bin/bash

set -e

VERSION=$1

mkdir -p /opt/techs

cd /usr/src

SUBVERSION=`echo $VERSION | cut -d "." -f 1`.`echo $VERSION | cut -d "." -f 2`

wget https://cache.ruby-lang.org/pub/ruby/$SUBVERSION/ruby-$VERSION.tar.gz
tar xf ruby-$VERSION.tar.gz
rm ruby-$VERSION.tar.gz

cd ruby-$VERSION
./configure --prefix=/opt/techs/ruby-$VERSION
make -j
make install

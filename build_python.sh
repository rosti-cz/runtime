#!/bin/sh

set -e

mkdir -p /opt/techs

VERSION=$1

wget https://www.python.org/ftp/python/`echo $VERSION | sed s/[a-z][0-9]\$//`/Python-$VERSION.tar.xz
tar xf Python-$VERSION.tar.xz
cd /usr/src/Python-$VERSION
./configure --prefix=/opt/techs/python-$VERSION
make -j
make install

test -e /opt/techs/python-$VERSION/bin/python || ln -s /opt/techs/python-$VERSION/bin/python3 /opt/techs/python-$VERSION/bin/python
test -e /opt/techs/python-$VERSION/bin/pip || ln -s /opt/techs/python-$VERSION/bin/pip3 /opt/techs/python-$VERSION/bin/pip

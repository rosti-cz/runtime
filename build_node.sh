#!/bin/bash

set -e

mkdir -p /opt/techs

VERSION=$1

cd /usr/src

wget http://nodejs.org/dist/v$VERSION/node-v$VERSION-linux-x64.tar.gz
tar xf node-v$VERSION-linux-x64.tar.gz
mv node-v$VERSION-linux-x64 /opt/techs/node-$VERSION
rm node-v$VERSION-linux-x64.tar.gz

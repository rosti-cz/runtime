#!/bin/bash

set -e

mkdir -p /opt/techs

VERSION=$1

cd /usr/src

wget https://github.com/denoland/deno/releases/download/v$VERSION/deno-x86_64-unknown-linux-gnu.zip
unzip deno-x86_64-unknown-linux-gnu.zip

mkdir -p /opt/techs/deno-$VERSION/bin
mv deno /opt/techs/deno-$VERSION/bin/deno

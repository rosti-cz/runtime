#!/bin/bash

set -e

VERSION=$1

mkdir -p /opt/techs

cd /usr/src

wget https://www.php.net/distributions/php-$VERSION.tar.bz2
tar xf php-$VERSION.tar.bz2
rm php-$VERSION.tar.bz2

test -e /usr/lib/x86_64-linux-gnu/libc-client.a || ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a

cd php-$VERSION
./configure --enable-fpm --with-mysqli --prefix=/opt/techs/php-$VERSION \
	    --with-config-file-path=/opt/techs/php-$VERSION/etc \
	    --with-config-file-scan-dir=/opt/techs/php-$VERSION/etc/conf.d/ \
        --sbindir=/opt/techs/php-$VERSION/bin \
	    --with-pdo-pgsql \
	    --with-zlib-dir \
	    --with-freetype \
	    --enable-mbstring \
	    --with-libxml-dir=/usr \
	    --enable-soap \
	    --enable-calendar \
	    --with-curl \
	    --with-mcrypt \
	    --with-zlib \
	    --enable-gd \
		--with-zip \
	    --with-pgsql \
	    --disable-rpath \
	    --enable-inline-optimization \
	    --with-bz2 \
	    --with-zlib \
	    --enable-sockets \
	    --enable-sysvsem \
	    --enable-sysvshm \
	    --enable-pcntl \
	    --enable-mbregex \
	    --enable-exif \
	    --enable-bcmath \
	    --with-mhash \
	    --with-pcre-regex \
	    --with-mysql \
	    --with-pdo-mysql \
	    --with-jpeg \
	    --with-png-dir \
	    --enable-gd-native-ttf \
	    --with-openssl \
	    --with-fpm-user=app\
	    --with-fpm-group=app\
	    --with-libdir=/lib/x86_64-linux-gnu \
	    --enable-ftp \
	    --with-gettext \
	    --with-xmlrpc \
	    --with-xsl \
	    --enable-opcache \
	    --with-imap \
	    --with-imap-ssl \
	    --with-sodium \
        --with-kerberos \
        --with-soapclient \
		--with-pear \
		--enable-intl \
		--with-webp
make -j
make install

mkdir -p /opt/techs/php-$VERSION/etc/conf.d/

cd /opt/techs/php-$VERSION/bin
curl -s https://getcomposer.org/installer | ./php -d allow_url_fopen=On
cd -

echo "no" | /opt/techs/php-$VERSION/bin/pecl install redis
echo "no" | /opt/techs/php-$VERSION/bin/pecl install imagick

echo "zend_extension=opcache.so" > /opt/techs/php-$VERSION/etc/conf.d/extensions.ini
echo "extension=redis.so" >> /opt/techs/php-$VERSION/etc/conf.d/extensions.ini

ln -s /srv/conf/php-fpm/php.ini /opt/techs/php-$VERSION/etc/conf.d/99-app.ini

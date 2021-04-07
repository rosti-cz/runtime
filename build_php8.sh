#!/bin/bash

set -e

VERSION=$1

mkdir -p /opt/techs

cd /usr/src

wget https://www.php.net/distributions/php-$VERSION.tar.bz2
tar xf php-$VERSION.tar.bz2
rm php-$VERSION.tar.bz2

# test -e /usr/lib/x86_64-linux-gnu/libc-client.a || ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a

cd php-$VERSION
./configure --enable-fpm --with-mysqli --prefix=/opt/techs/php-$VERSION \
	    --with-config-file-path=/opt/techs/php-$VERSION/etc \
	    --with-config-file-scan-dir=/opt/techs/php-$VERSION/etc/conf.d/ \
        --sbindir=/opt/techs/php-$VERSION/bin \
	    --with-pdo-pgsql \
	    --with-zlib-dir \
	    --with-freetype \
	    --enable-mbstring \
	    --enable-soap \
	    --enable-calendar \
	    --with-curl \
	    --with-zlib \
	    --enable-gd \
		--with-zip \
	    --with-pgsql \
	    --disable-rpath \
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
	    --with-pdo-mysql \
	    --with-jpeg \
	    --with-openssl \
	    --with-fpm-user=app\
	    --with-fpm-group=app\
	    --with-libdir=/lib/x86_64-linux-gnu \
	    --enable-ftp \
	    --with-gettext \
	    --with-xsl \
	    --enable-opcache \
	    --with-imap \
	    --with-imap-ssl \
	    --with-sodium \
        --with-kerberos \
		--with-pear \
		--enable-intl \
		--with-webp
make -j
make install

mkdir -p /opt/techs/php-$VERSION/etc/conf.d/
ln -s /srv/conf/php-fpm/php.ini /opt/techs/php-$VERSION/etc/conf.d/app.ini

cd /opt/techs/php-$VERSION/bin
curl -s https://getcomposer.org/installer | ./php -d allow_url_fopen=On
cd -

echo "no" | /opt/techs/php-$VERSION/bin/pecl install redis

echo "zend_extension=opcache.so" > /opt/techs/php-$VERSION/etc/conf.d/extensions.ini
echo "extension=redis.so" >> /opt/techs/php-$VERSION/etc/conf.d/extensions.ini
# Not supported yet
# https://github.com/Imagick/imagick/issues/358
# echo "no" | /opt/techs/php-$VERSION/bin/pecl install imagick
# echo "extension=imagick.so" >> /opt/techs/php-$VERSION/etc/conf.d/extensions.ini

ln -s /srv/conf/php-fpm/php.ini /opt/techs/php-$VERSION/etc/conf.d/99-app.ini

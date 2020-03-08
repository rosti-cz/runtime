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
	    --with-freetype-dir \
	    --enable-mbstring \
	    --with-libxml-dir=/usr \
	    --enable-soap \
	    --enable-calendar \
	    --with-curl \
	    --with-mcrypt \
	    --with-zlib \
	    --with-gd \
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
	    --enable-zip \
	    --with-pcre-regex \
	    --with-mysql \
	    --with-pdo-mysql \
	    --with-jpeg-dir=/usr \
	    --with-png-dir=/usr \
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
        --with-kerberos \
        --with-soapclient \
		--with-pear \
		--enable-gd \
		--with-jpeg
make -j
make install

mkdir -p /opt/techs/php-$VERSION/etc/conf.d/
ln -s /srv/conf/php-fpm/php.ini /opt/techs/php-$VERSION/etc/conf.d/app.ini

echo "no" | /opt/techs/php-$VERSION/bin/pecl install redis

echo "extension=redis.so" > /opt/techs/php-$VERSION/etc/conf.d/extensions.ini

# Composer

/opt/techs/php-$VERSION/bin/php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
/opt/techs/php-$VERSION/bin/php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
/opt/techs/php-$VERSION/bin/php composer-setup.php --install-dir=/opt/techs/php-$VERSION/bin/

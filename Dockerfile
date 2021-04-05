FROM debian:buster

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget gpg

RUN echo "deb http://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales libffi-dev \
libssl-dev default-libmysqlclient-dev ca-certificates libpq-dev libjpeg62 libjpeg-dev \
libpng-dev libpng-dev build-essential git mercurial build-essential \
libbz2-dev libsqlite3-dev libreadline-dev zlib1g-dev libncurses5-dev \
libgdbm-dev libgd-dev cron git subversion vim nano mc htop procps \
dropbear gettext wget redis-server memcached supervisor curl ssh \
mariadb-client postgresql-client-12 postgresql-12-postgis-3-scripts bind9-host dnsutils nginx \
libxml2-dev libxslt1-dev openssh-sftp-server links2 lynx \
imagemagick libmagick++-6.q16-dev libmagick++-6.q16hdri-dev libmagickwand-dev ncdu libsodium-dev \
python3 python3-pip python3-virtualenv \
libcurl4-openssl-dev python-dev libproj-dev gdal-bin libmemcached-dev swig mutt \
ffmpeg libyaml-dev libc-client2007e-dev libonig-dev libkrb5-dev dialog \
whiptail tmux rsync nmap libzip-dev libfreetype6-dev \
jpegoptim optipng pngquant gifsicle webp libvpx-dev libwebp-dev # User requirement (svgo not available)

WORKDIR /srv

RUN useradd -d /srv app -s /bin/bash
RUN usermod -G crontab -a app
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Prague /etc/localtime

ADD /etc/locale.gen /etc/
RUN locale-gen
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV TERM       xterm

#############
# Techs
#############

## Node.js

WORKDIR /usr/src
ADD build_node.sh /usr/local/bin/build_node.sh
# 2021/02
RUN build_node.sh 15.8.0
RUN build_node.sh 14.15.4

## Python

WORKDIR /usr/src
ADD build_python.sh /usr/local/bin/build_python.sh
# 2020/01
RUN build_python.sh 3.8.5
# 2020/12
RUN build_python.sh 3.9.1

## PHP

WORKDIR /usr/src
ADD build_php.sh /usr/local/bin/build_php.sh
# 2020/01
RUN build_php.sh 7.4.9
# 2021/02
RUN build_php.sh 7.4.15

## PHP 8

# 2021/02
ADD build_php8.sh /usr/local/bin/build_php8.sh
RUN build_php8.sh 8.0.3

## Ruby
WORKDIR /usr/src
ADD build_ruby.sh /usr/local/bin/build_ruby.sh
# 2020/11
RUN build_ruby.sh 2.7.2
# 2020/12
RUN build_ruby.sh 3.0.0

## Deno
ADD build_deno.sh /usr/local/bin/build_deno.sh
# 2021/02
RUN build_deno.sh 1.7.2

#############

## Support tools and miscellaneous stuff

RUN rm -f /etc/cron.d/* /etc/cron.daily/* /etc/cron.hourly/* /etc/cron.monthly/* /etc/cron.weekly/*

ADD /scripts/enable_redis.sh /usr/local/bin/enable-redis
ADD /scripts/enable_memcached.sh /usr/local/bin/enable-memcached
RUN chmod 755 /usr/local/bin/*

ADD /etc/supervisord.conf /etc/supervisor/supervisord.conf
ADD /examples /opt/examples
ADD /etc/bashrc_local /opt/etc/bashrc_local
ADD /etc/bash_profile /opt/etc/bash_profile
ADD /etc/vimrc /opt/etc/vimrc
RUN mkdir -p /opt/etc/bashrc
RUN mkdir -p /opt/etc/appinit
ADD /etc/bashrc/common.sh /opt/etc/bashrc/
ADD /etc/nginx.conf /etc/nginx/nginx.conf

RUN rmdir /var/lib/nginx
RUN ln -s /srv/var/nginx /var/lib/nginx
RUN chown app:app /var/log/nginx -R

RUN chown app:app /home -R

# Start script

ADD /start.sh /start.sh
RUN chmod 755 /start.sh

## Roští script

RUN apt-get install -y fish
ADD ./gen_rosti.fish /usr/local/bin/
ADD ./rosti.sh.tmp /usr/src/
ADD ./Dockerfile /usr/src/
RUN cd /usr/src && /usr/local/bin/gen_rosti.fish > /usr/local/bin/rosti && chmod 755 /usr/local/bin/rosti

## Cleaning
RUN apt-get clean && rm -rf /usr/src/*


VOLUME /srv
WORKDIR /srv
EXPOSE 8000 22

ENTRYPOINT ["/start.sh"]

FROM debian:buster

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales libffi-dev \
libssl-dev default-libmysqlclient-dev ca-certificates libpq-dev libjpeg62 libjpeg-dev \
libpng-dev libpng-dev build-essential git mercurial build-essential \
libbz2-dev libsqlite3-dev libreadline-dev zlib1g-dev libncurses5-dev \
libssl-dev libgdbm-dev cron git mercurial subversion vim nano mc htop procps \
subversion dropbear gettext wget redis-server memcached supervisor curl ssh \
mariadb-client postgresql-client bind9-host dnsutils nginx \
libxml2-dev libxslt1-dev openssh-sftp-server links2 lynx \
imagemagick libmagickwand-dev ncdu \
libcurl4-openssl-dev python3 python3-pip python3-virtualenv \
libcurl4-openssl-dev python-dev libproj-dev gdal-bin libmemcached-dev swig mutt \
imagemagick ffmpeg libyaml-dev libc-client2007e-dev libonig-dev libkrb5-dev dialog \
whiptail tmux rsync nmap
 
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
# 2020/01
RUN build_node.sh 13.7.0
# 2020/01
RUN build_node.sh 12.14.1

## Python

WORKDIR /usr/src
ADD build_python.sh /usr/local/bin/build_python.sh
# 2020/01
RUN build_python.sh 3.8.1

## PHP

WORKDIR /usr/src
ADD build_php.sh /usr/local/bin/build_php.sh
# 2020/01
RUN build_php.sh 7.4.2

## Roští script

ADD rosti.sh /usr/local/bin/rosti

#############

## Support tools and miscellaneous stuff

ADD /start.sh /start.sh
RUN chmod 755 /start.sh

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

## Cleaning
RUN apt-get clean && rm -rf /usr/src/*


VOLUME /srv
WORKDIR /srv
EXPOSE 8000 22

ENTRYPOINT ["/start.sh"]

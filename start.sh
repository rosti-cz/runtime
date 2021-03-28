#!/bin/sh

##################################
# Basic structure and purpose file
##################################

for d in /srv/log /srv/conf /srv/run /srv/conf/supervisor.d /srv/var; do
    if [ ! -e $d ]; then
        mkdir -p $d
        chown app:app $d
    fi
done

# Bin directory where active tech is located along other tools
mkdir -p /srv/bin
# Directory where Nginx stored request bodies
mkdir -p /srv/var/nginx/
# Run directory where PID files, socket files a other runtime stuff is located
mkdir -p /srv/run
# Configuration store for Nginx
mkdir -p /srv/conf/nginx.d

###################
# Clear tmp files
###################

rm -f /srv/run/*.sock
rm -f /srv/run/*.pid

################
# Common things
################

# SSH password from file and from system env
if [ -e /srv/.rosti ]; then
    echo "app:`cat /srv/.rosti`" | chpasswd
    # file with ssh password has different owner
    chown root:root /srv/.rosti
    chmod 600 /srv/.rosti
fi
if [ -n "$SSHPASS" ]; then
    echo "app:$SSHPASS" | chpasswd
fi

# Dropbear settings and certificates
if [ ! -e /srv/conf/dropbear ]; then
    mkdir -p /srv/conf/dropbear

    chmod 700 /srv/conf/dropbear
    chown root:root /srv/conf/dropbear
fi
#rm /etc/dropbear/dropbear_rsa_host_key /etc/dropbear/dropbear_dss_host_key
test -e /srv/conf/dropbear/dropbear_rsa_host_key || dropbearkey -t rsa -f /srv/conf/dropbear/dropbear_rsa_host_key
test -e /srv/conf/dropbear/dropbear_dss_host_key || dropbearkey -t dss -f /srv/conf/dropbear/dropbear_dss_host_key
chmod 700 /srv/conf/dropbear
chmod 600 /srv/conf/dropbear/*
chown -R root:root /srv/conf/dropbear
cp /srv/conf/dropbear/* /etc/dropbear/

# vimrc
if [ ! -e /srv/.vimrc ]; then
    cp /opt/etc/vimrc /srv/.vimrc
fi

# Crontab
test ! -e /srv/conf/crontab && touch /srv/conf/crontab
if [ -e  /srv/conf/crontab ]; then
    crontab -u app /srv/conf/crontab
fi
chown app:app /srv/conf/crontab

# Start secondary daemons
echo "Starting cron .."
/usr/sbin/cron
echo "Starting dropbear .."
dropbear -w -d /srv/conf/dropbear/dropbear_dss_host_key -r /srv/conf/dropbear/dropbear_rsa_host_key

# BASHRC
if [ ! -e /srv/.bashrc ]; then
    cp /opt/etc/bashrc_local /srv/.bashrc
    chown app:app /srv/.bashrc
fi
if [ ! -e /srv/.bash_profile ]; then
    cp /opt/etc/bash_profile /srv/.bash_profile
fi

cd /srv

#################
# Initialization
#################

# Install custom packages
if [ -e /srv/.extra_packages ]; then
    apt-get update -y
    apt-get install -y `cat /srv/.extra_packages | sed "s/;//g" | sed "s/\n/ /g"`
fi

# Init scripts runned under root
if [ -e /opt/etc/script.d/* ]; then
    for f in `ls /opt/script.d`; do
        /bin/sh /opt/etc/script.d/$f
    done
fi

# Init scripts runned under app user
if [ -e /opt/etc/appinit/* ]; then
    for f in `ls /opt/etc/appinit/*`; do
        su app -c "/bin/sh $f"
    done
fi

# Permissions for app on /srv
if [ ! -e /srv/.chowned ]; then
    chown app:app /srv -R
    touch /srv/.chowned
    chown root:root /srv/.chowned
    chmod 644 /srv/.chowned
fi

# User's init script
if [ -e /srv/app/init.sh ]; then
    echo "Starting /srv/app/init.sh .."
    chmod 755 /srv/app/init.sh
    su app -c /srv/app/init.sh
fi

# Custom /etc/ssl/openssl.cnf
if [ -e /srv/conf/openssl.cnf ]; then
    rm /etc/ssl/openssl.cnf
    cp /srv/conf/openssl.cnf /etc/ssl/openssl.cnf
fi

####################
# Default Nginx page
####################

if [ `ls /srv/conf/nginx.d | wc -l` -eq 0 ]; then
    echo ".. no nginx configuration found, adding default page"
    su app -c "mkdir -p /srv/conf/nginx.d"
    su app -c "cp /opt/examples/nginx/default.conf /srv/conf/nginx.d/default.conf"
fi

if [ ! -e /srv/conf/supervisor.d/nginx.conf ]; then
    echo ".. nginx configuration not found in supervisor, adding it now"
    su app -c "cp /opt/examples/nginx/supervisor.conf /srv/conf/supervisor.d/nginx.conf"
fi

su app -c "supervisord -n -c /etc/supervisor/supervisord.conf"

#!/bin/bash

. ~/.bashrc

WIDTH=180
HEIGHT=25

TECHDIR=/opt/techs
PRIMARYDIR=/srv/bin/primary_tech

# Usage: rosti php|python|node|memcached|redis OPTINAL_VERSION
#
# This script helps to configure the environment for selected
# language/technology/service. The language or service can be
# selected via TUI menu or optinal arguments.

QUICK_TECH=$1
QUICK_VERSION=$2

# These environment variables can be set for testing:
# TESTMODE - 1 if test mode is enabled, it skips whiptail
# MENUITEM - selected menu item
# TECH - selected tech
# SERVICE - selected service


function setTech() {
    tech=$1

    # Activation of primary tech bin directory
    test ! -e $PRIMARYDIR || unlink $PRIMARYDIR
    ln -s $TECHDIR/$tech/bin $PRIMARYDIR

    # Parse name of the tech - like python or node
    name=`echo $tech | cut -d"-" -f 1`

    # If /srv/app doesn't exist we will use examples files to create it
    if [ ! -e /srv/app ]; then
        mkdir -p /srv/conf/supervisor.d
        echo "NOTE: /srv/app doesn't exists, creating it from $tech example application"
        mkdir -p /srv/app
        cp -a /opt/examples/$name/* /srv/app/
        mv /srv/app/supervisor.conf /srv/conf/supervisor.d/$name.conf
    else
        echo "IMPORTANT: /srv/app found so no configuration or files are copied, make sure the application is ok after this process"
    fi

    # Pythoon specific stuff
    if [ "$name" = "python" ]; then
        if [ -e /srv/venv ]; then
            echo "IMPORTANT: /srv/venv exists, if you have changed python version, make sure to create or update the virtualenv:"
            echo 
            echo "    rm -rf /srv/venv"
            echo "    python3 -m venv /srv/venv)"
            echo
            echo "Don't forget to backup the old venv if necessary."
        else
            echo ".. creating new venv in /srv/venv"
            test -e /srv/venv || $PRIMARYDIR/python3 -m venv /srv/venv
            /srv/venv/bin/pip install gunicorn
            /srv/venv/bin/pip install bottle
        fi
    fi

    # PHP specific stuff
    if [ "$name" = "php" ]; then
        mkdir -p /srv/conf/php-fpm/pool.d/

        # Copy config if needed
        test -e /srv/conf/php-fpm/php-fpm.conf || mv /srv/app/php-fpm.conf /srv/conf/php-fpm/php-fpm.conf
        test -e /srv/conf/php-fpm/pool.d/app.conf || mv /srv/app/pool_app.conf /srv/conf/php-fpm/pool.d/app.conf
        test -e /srv/conf/php-fpm/php.ini || mv /srv/app/php.ini /srv/conf/php-fpm/php.ini

        ln -s /srv/conf/php-fpm/php.ini /opt/techs/$tech/etc/conf.d/app.ini

        # And remove unneeded ones
        # TODO: not sure how good idea this is
        rm -f /srv/app/php-fpm.conf /srv/app/pool_app.conf /srv/app/php.ini /srv/app/nginx.conf
    fi

    # Node specific stuff
    if [ "$name" = "node" ]; then
        /opt/techs/$tech/bin/npm config set prefix "/srv/.npm-packages"
        /opt/techs/$tech/bin/npm install -g yarn@berry
    fi

    # Remove default config in Nginx
    test -e /srv/conf/nginx.d/default.conf && rm -f /srv/conf/nginx.d/default.conf

    # Same thing we do for nginx but if the file exist it's not rewritten.
    if [ ! -e /srv/conf/nginx.d/app.conf ]; then
        mkdir -p /srv/conf/nginx.d
        if [ "$name" = "php" ]; then
            cp /opt/examples/php/nginx.conf /srv/conf/nginx.d/app.conf
        else
            cp /opt/examples/nginx/nginx.conf /srv/conf/nginx.d/app.conf
        fi
        echo ".. app configuration for nginx not found, adding it - please check /srv/conf/nginx.d/app.conf and make sure it fits your code"
        
    fi

    # We load new configuration into supervisor and it's automatically started or restarted if needed
    supervisorctl reread
    supervisorctl update
    nginx -s reload

    echo "NOTE: this tool doesn't restart existing processes, if it's needed, please, do it manually"

    echo
    if [ ! "$TESTMODE" = "1" -a -z "$QUICK_TECH" ]; then
        read -p "Check the output and hit enter to continue"
    else
        exit 0
    fi
}

function setService() {
    service=$1

    case $service in
        "redis")
            echo ".. adding redis into supervisor and copying config file into /srv/conf/redis.conf"
            mkdir -p /srv/var/redis
            cp /opt/examples/redis/supervisor.conf /srv/conf/supervisor.d/redis.conf
            cp /opt/examples/redis/redis.conf /srv/conf/redis.conf
            supervisorctl reread
            supervisorctl update
            echo "NOTE: please, check configuration file /srv/conf/redis.conf and update it if needed"
            echo "NOTE: Redis server is available at localhost:6379"

            echo
            if [ ! "$TESTMODE" = "1" -a -z "$QUICK_TECH" ]; then
                read -p "Check the output and hit enter to continue"
            else
                exit 0
            fi
        ;;
        "memcached")
            echo ".. adding memcached into supervisor"
            cp /opt/examples/memcached/supervisor.conf /srv/conf/supervisor.d/memcached.conf
            supervisorctl reread
            supervisorctl update
            echo "NOTE: Memcached server is available at localhost:11211"

            echo
            if [ ! "$TESTMODE" = "1" -a -z "$QUICK_TECH" ]; then
                read -p "Check the output and hit enter to continue"
            else
                exit 0
            fi
        ;;
        "*")
            continue
        ;;
    esac
}

# Use two parameters to handle everything this script allows to user
function quickTech() {
    TECH=$1
    VERSION=$2

    case $TECH in
        "python")
            if [ -z "$VERSION" ]; then
                VERSION=3.8.5
            fi
            setTech $TECH-$VERSION
        ;;
        "php")
            if [ -z "$VERSION" ]; then
                VERSION=7.4.9
            fi
            setTech $TECH-$VERSION
        ;;
        "node")
            if [ -z "$VERSION" ]; then
                VERSION=14.8.0
            fi
            setTech $TECH-$VERSION
        ;;
        "memcached")
            setService $TECH
        ;;
        "redis")
            setService $TECH
        ;;
    esac
}

# If parameters with tech and possibly version are given we just use those
if [ -n "$QUICK_TECH" ]; then
    quickTech $QUICK_TECH $QUICK_VERSION
    exit 0
fi

# We will use EDITOR environment variables if possible
if [ "$EDITOR" = "" ]; then
    export EDITOR=nano
fi

while /bin/true; do
    if [ "$MENUITEM" = "" ]; then
    menuitem=$(whiptail --menu "Choose what to do" $HEIGHT $WIDTH 6 \
            "tech" "  Activaton of primary tech" \
            "services" "  Enable additional services (Redis, Memcached, ..)" \
            "cron" "  Update crontab" \
            "exit"  "  Exit" \
            3>&1 1>&2 2>&3)
    else
        menuitem=$MENUITEM
    fi

    case $menuitem in
        # Activation of one of the available tech
        # Only one tech can be enabled same time but it's possible to use any of them from /opt/techs
        "tech")
            if [ "$TECH" = "" ]; then
                tech=$(whiptail --menu "Select tech" $HEIGHT $WIDTH 6 \
                        "python-3.8.2" "  Python 3.8.2" \
                        "python-3.8.5" "  Python 3.8.5" \
                        "node-13.12.0" "  Node 13.12.0" \
                        "node-14.8.0" "  Node 14.8.0" \
                        "node-12.16.1" "  Node 12.16.1" \
                        "node-12.18.3" "  Node 12.18.3" \
                        "php-7.4.4" "  PHP 7.4.4" \
                        "php-7.4.9" "  PHP 7.4.9" \
                        "back"  "  Go back" \
                        3>&1 1>&2 2>&3)
            else
                tech=$TECH
            fi

            if [ "$tech" = "back" -o "$tech" = "" ]; then
                continue
            fi

            setTech $tech
        ;;
        # Services like small tools, databases or so to support the running app
        "services")
            if [ "$SERVICE" = "" ]; then
                service=$(whiptail --menu "Select service to be enabled" $HEIGHT $WIDTH 6 \
                        "memcached" "  Memcached" \
                        "redis" "  Redis" \
                        "back"  "  Go back" \
                        3>&1 1>&2 2>&3)
            else
                service=$SERVICE
            fi
            
            setService $service
        ;;
        # Simpler crontab editor
        "cron")
            $EDITOR /srv/conf/crontab && \
            crontab /srv/conf/crontab

            echo
            if [ ! "$TESTMODE" = "1" -a -z "$QUICK_TECH" ]; then
                read -p "Check the output and hit enter to continue"
            else
                exit 0
            fi
        ;;
        "exit")
            echo "Bye bye!"
            exit 0
        ;;
    esac
done

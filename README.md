# Roští.cz Runtime

Runtime image designed for our hosting service. It's designed for multiple versions of Node.js, PHP and Python interpreters. It runs SSH, cron daemon and supervisord as process manager.

The goal of the image is to deliver versatile environment different kind of applications.

* [Documentation (czech)](https://docs.rosti.cz/runtime/main/).

The image is based on Debian 10 Buster and it's size is around 2.5 GB when it's squashed.

** Supported languages **

* Python 3.8.1
* Python 3.8.2
* Node.js 13.7.0
* Node.js 13.12.0
* Node.js 12.14.1
* Node.js 12.16.1
* PHP 7.4.2
* PHP 7.4.4

** Additional tools **

* Memcached
* Redis
* crond
* Supervisord
* Nginx
* Dropbear

## Test

To run tests you can check integrated workflow, but all you need are those two commands:

    make test

If you prefer Podman, use this command to build the image:

    make DOCKER=podman test

This is useful in Fedora.

## Additional info

### Default user

Image uses system user *app* to run the application code.

### SSH password

The image runs dropbear at start along crond and supervisord. If you want to set password for next start of the container, save it into this file:

    /srv/.rosti

Dynamically it can be set like this:

    echo "app:PASSWORD" | chpasswd

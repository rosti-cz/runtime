#!/bin/bash

if [ -z "$DOCKER" ]; then
    DOCKER=docker
fi

CONTAINER_NAME=runtime-test
I=1
COUNT=5
PROBLEM=0

function run() {
    $DOCKER run -d --rm --name $CONTAINER_NAME rosti/runtime:dev > /dev/null
    sleep 5
}
function stop() {
    $DOCKER stop $CONTAINER_NAME > /dev/null
    sleep 5
}

# Default page
run
$DOCKER exec -ti $CONTAINER_NAME curl http://localhost:8000 | grep "<title>Roští.cz</title>" > /dev/null
if [ $? -eq 0 ]; then
    echo "$I/$COUNT default response correct"
else
    echo "$I/$COUNT default response incorrect"
    PROBLEM=1
fi

I=$((I+1))
stop
###############


# Node.js 12.14.1
run

$DOCKER exec -ti -e TESTMODE=1 -e MENUITEM=tech -e TECH=node-12.14.1 $CONTAINER_NAME su app -c rosti > /dev/null
sleep 3
$DOCKER exec -ti $CONTAINER_NAME curl http://localhost:8000 | grep package.json > /dev/null
if [ $? -eq 0 ]; then
    echo "$I/$COUNT Node.js 12.14.1 response correct"
else
    echo "$I/$COUNT Node.js 12.14.1 response incorrect"
    PROBLEM=1
fi

I=$((I+1))
stop
###############

# Node.js 13.7.0
run

$DOCKER exec -ti -e TESTMODE=1 -e MENUITEM=tech -e TECH=node-13.7.0 $CONTAINER_NAME su app -c rosti > /dev/null
sleep 3
$DOCKER exec -ti $CONTAINER_NAME curl http://localhost:8000 | grep package.json > /dev/null
if [ $? -eq 0 ]; then
    echo "$I/$COUNT Node.js 13.7.0 response correct"
else
    echo "$I/$COUNT Node.js 13.7.0 response incorrect"
    PROBLEM=1
fi

I=$((I+1))
stop
###############


# Python 3.8.2
run

$DOCKER exec -ti -e TESTMODE=1 -e MENUITEM=tech -e TECH=python-3.8.1 $CONTAINER_NAME su app -c rosti > /dev/null
sleep 5
$DOCKER exec -ti $CONTAINER_NAME curl http://localhost:8000 | grep "app.py" > /dev/null
if [ $? -eq 0 ]; then
    echo "$I/$COUNT Python 3.8.1 response correct"
else
    echo "$I/$COUNT Python 3.8.1 response incorrect"
    PROBLEM=1
fi

I=$((I+1))
stop
###############

# PHP 7.4.2
run

$DOCKER exec -ti -e TESTMODE=1 -e MENUITEM=tech -e TECH=php-7.4.2 $CONTAINER_NAME su app -c rosti > /dev/null
sleep 5
$DOCKER exec -ti $CONTAINER_NAME curl http://localhost:8000 | grep "PHP aplikaci" > /dev/null
if [ $? -eq 0 ]; then
    echo "$I/$COUNT PHP 7.4.2 response correct"
else
    echo "$I/$COUNT PHP 7.4.2 response incorrect"
    PROBLEM=1
fi

I=$((I+1))
stop
###############

if [ "$PROBLEM" = "0" ]; then
    echo
    echo "All OK"
    exit 0
else
    echo
    echo "Problem found"
    exit 1
fi

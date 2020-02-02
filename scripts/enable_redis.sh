#!/bin/sh

mkdir -p /srv/var/redis
mkdir -p /srv/run
cp /opt/conf/redis.conf /srv/conf/

cat << EOF > /srv/conf/supervisor.d/redis.conf
[program:redis]
command=redis-server /srv/conf/redis.conf
autostart=true
autorestart=true
stdout_logfile=/srv/log/redis.log
stdout_logfile_maxbytes=2MB
stdout_logfile_backups=5
stdout_capture_maxbytes=2MB
stdout_events_enabled=false
redirect_stderr=true
EOF

supervisorctl reread
supervisorctl update

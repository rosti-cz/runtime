#!/bin/sh

cat << EOF > /srv/conf/supervisor.d/memcached.conf
[program:memcached]
command=/usr/bin/memcached -m 64
autostart=true
autorestart=true
stdout_logfile=/srv/log/memcached.log
stdout_logfile_maxbytes=2MB
stdout_logfile_backups=5
stdout_capture_maxbytes=2MB
stdout_events_enabled=false
redirect_stderr=true
EOF

supervisorctl reread
supervisorctl update

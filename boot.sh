#!/bin/bash

/etc/init.d/postgresql start
/etc/init.d/redis-server start

rm -f /var/run/ospd.pid
ospd-openvas --log-level=DEBUG -l /usr/local/var/log/ospd-openvas.log

until pg_isready; do sleep 1; done

gvmd --osp-vt-update=/var/run/ospd/ospd.sock --unix-socket /var/run/gvmd.sock --listen-owner=openvas 

gsad --munix-socket /var/run/gvmd.sock

tail -f /dev/null
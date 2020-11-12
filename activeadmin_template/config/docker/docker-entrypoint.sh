#!/bin/bash

service ssh start

#bundle install --without development test
bundle install

# clean tmp/pids/server.pid
echo "clean up tmp/pids/server.pid"
PID=tmp/pids/server.pid
if test -f "$PID"; then
	rm tmp/pids/server.pid
fi
rails s -b 0.0.0.0
tail -f /dev/null # keep container running

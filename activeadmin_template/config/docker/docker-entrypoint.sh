#!/bin/bash

service ssh start

bundle install --without development test

# clean tmp/pids/server.pid
echo "clean up tmp/pids/server.pid"
rm tmp/pids/server.pid
rails s -b 0.0.0.0

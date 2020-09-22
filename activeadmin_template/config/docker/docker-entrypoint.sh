#!/bin/bash

service ssh start

rm tmp/pids/server.pid

# for production
bundle install --without development test
rails s -b 0.0.0.0 # it can keep container running

# for development or debug
# bundle install --with development
#tail -f /dev/null # keep container running

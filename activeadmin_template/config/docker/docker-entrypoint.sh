#!/bin/bash

bundle install
service ssh start
rails s -b 0.0.0.0

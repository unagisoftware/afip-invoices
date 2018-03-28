#!/bin/bash
# https://stackoverflow.com/a/38732187/1935918
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

# if [ -f /app/tmp/unicorn.pid ]; then
#   rm /app/tmp/unicorn.pid
# fi

if [[ $MIGRATE = "true" ]]; then
  bundle exec rake db:migrate
fi

# if [[ -z $REQUEST_TIMEOUT ]]; then
#   REQUEST_TIMEOUT=60
# fi

# sed -i "s/REQUEST_TIMEOUT/${REQUEST_TIMEOUT}/" /app/docker/unicorn.rb

exec "$@"
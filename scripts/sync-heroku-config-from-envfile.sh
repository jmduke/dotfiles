#!/usr/bin/env bash

# Remove comments and any spaces in lines
heroku config:set --app $1 $(sed 's:#.*$::g' "$2" | tr -d ' ')
#!/bin/bash
fsmonitor -p -d js '!index.js' '!templates.js' '!application.js' ember build -o ../../public/javascripts/app_list.js -d

#!/bin/sh
./build.sh && ruby -run -ehttpd public -p 8086

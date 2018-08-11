#!/usr/bin/env bash

set -euo pipefail

mkdir -p public
cp -r static/* public

elm-make src/Main.elm --output public/shotclock.js
uglifyjs public/shotclock.js -o public/shotclock.min.js

#!/bin/sh

set -e

DARKLUA_CONFIG=$1
BUILD_OUTPUT=$2

rm -rf temp
yarn workspaces focus --production
npx --yes npmluau

rm -rf temp
mkdir -p temp
cp -r src/ temp/
cp -rL node_modules/ temp/

./scripts/remove-tests.sh temp

rm -f "$BUILD_OUTPUT"
mkdir -p $(dirname "$BUILD_OUTPUT")

darklua process --config "$DARKLUA_CONFIG" temp/src/init.lua "$BUILD_OUTPUT"

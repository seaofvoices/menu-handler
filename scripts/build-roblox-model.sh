#!/bin/sh

set -e

DARKLUA_CONFIG=$1
BUILD_OUTPUT=$2

rm -rf temp
yarn workspaces focus --production
npx --yes npmluau

mkdir -p temp
cp -r main.lua temp/
cp -r src/ temp/
cp -rL node_modules/ temp/
cp "$DARKLUA_CONFIG" "temp/$DARKLUA_CONFIG"

./scripts/remove-tests.sh temp

rojo sourcemap model.project.json -o temp/sourcemap.json

cd temp

darklua process --config "$DARKLUA_CONFIG" main.lua main.lua
darklua process --config "$DARKLUA_CONFIG" src src
darklua process --config "$DARKLUA_CONFIG" node_modules node_modules

cd ..

cp model.project.json temp/

rm -f "$BUILD_OUTPUT"
mkdir -p $(dirname "$BUILD_OUTPUT")

rojo build temp/model.project.json -o "$BUILD_OUTPUT"

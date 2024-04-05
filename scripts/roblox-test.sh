#!/bin/sh

set -e

DARKLUA_CONFIG=".darklua-tests.json"

rm -rf temp
yarn install
yarn prepare

rojo sourcemap test-place.project.json -o sourcemap.json

darklua process --config $DARKLUA_CONFIG jest.config.lua temp/jest.config.lua
darklua process --config $DARKLUA_CONFIG scripts/roblox-test.server.lua temp/scripts/roblox-test.server.lua
darklua process --config $DARKLUA_CONFIG node_modules temp/node_modules
darklua process --config $DARKLUA_CONFIG src temp/src

cp test-place.project.json temp/

rojo build temp/test-place.project.json -o temp/test-place.rbxl

run-in-roblox --place temp/test-place.rbxl --script temp/scripts/roblox-test.server.lua

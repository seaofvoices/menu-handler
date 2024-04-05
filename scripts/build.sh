#!/bin/sh

set -e

scripts/build-single-file.sh .darklua-bundle.json build/menu-handler.lua
scripts/build-single-file.sh .darklua-bundle-dev.json build/debug/menu-handler.lua
scripts/build-roblox-model.sh .darklua.json build/menu-handler.rbxm
scripts/build-roblox-model.sh .darklua-dev.json build/debug/menu-handler.rbxm

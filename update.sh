#!/bin/bash
#
# This Scritp updates the . files from git and bootstraps them into the home directory

git pull

git submodule update --init --recursive

./bootstrap.sh


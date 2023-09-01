#!/bin/bash

if [[ $(uname -s) == "CYGWIN"* ]]; then
    # create native symbolic links
    export CYGWIN=winsymlinks:native
    export DISPLAY=:0.0
fi

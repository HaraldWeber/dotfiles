#!/bin/bash
function genpwd() {
for i in {1..10}
do
    head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 16; echo
done
}
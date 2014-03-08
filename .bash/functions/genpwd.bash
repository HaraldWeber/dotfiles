#!/bin/bash
function genpwd() {
PWD_LEN=$1
COUNT=$2
if [[ -z "${PWD_LEN}" ]]; then
    PWD_LEN=8
fi
if [[ -z "${COUNT}" ]]; then
    COUNT=10
fi
for i in $(eval echo "{1..$COUNT}")
do
    head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c ${PWD_LEN}; echo
done
# echo "Usage: genpwd <Password Length> <Count>" > /dev/stderr
# echo "Standard is genpwd 8 10" >&2
}

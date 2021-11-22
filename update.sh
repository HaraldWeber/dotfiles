#!/bin/bash
#
# This Scritp updates the . files from git and bootstraps them into the home directory

git pull

# vim plugins
GITHUB="https://github.com"
VIM_PLUGINS="${GITHUB}/altercation/vim-colors-solarized"

for PLUGIN in ${VIM_PLUGINS}
do
    PLUGIN_NAME=$(basename ${PLUGIN})
    LOCAL_REPO=".vim/pack/bundle/start/${PLUGIN_NAME}"
    git clone --depth 1 "${PLUGIN}" "${LOCAL_REPO}" 2> /dev/null || git -C "${LOCAL_REPO}" pull
done

./bootstrap.sh


#!/bin/bash

rm -r ~/.bash
rm -r ~/.screen
rm -r ~/.vim
rsync --exclude "*/.git" --exclude ".git" --exclude ".directory" --exclude ".gitignore" --exclude ".gitmodules" --exclude "bootstrap.sh" --exclude "update.sh" --exclude "README.md" -av .  ~/
source ~/.bashrc

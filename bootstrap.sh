#!/bin/bash
rsync --exclude "*/.git" --exclude ".git" --exclude ".directory" --exclude ".gitignore" --exclude ".gitmodules" --exclude "bootstrap.sh" -av . ~/

#!/bin/bash
rsync --exclude "*/.git" --exclude ".git" --exclude ".directory" --exclude ".gitignore" --exclude "bootstrap.sh" -av . ~/
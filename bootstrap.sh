#!/bin/bash
rsync --exclude "*/.git" --exclude ".git" --exclude "bootstrap.sh" -av . ~/
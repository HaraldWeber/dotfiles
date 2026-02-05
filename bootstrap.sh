#!/bin/bash
set -euo pipefail
#
# This script links some config files from the dotfiles.git repo to the home direcotry.
#
# Author    Harald Weber <harald.h.weber@gmail.com>
#

# List which variables should not be linked to the home diretory.
EXCLUDED_FILES='. .. bootstrap.sh etc .git .gitignore .gitmodules README.md update.sh check_tools.bash config'

# include some checking functions
source check_tools.bash

# Check for bash verison > 3
if [[ $(checkBashVersion) -ne "0" ]]
then
    echo Bash version >= 4 is required
    exit 1
fi

# Check if the HOME variable is set.
if [[ ! -d "${HOME}" ]] 
then
    HOME=~/
    echo "Setting HOME to ${HOME}"
fi

# Set the directory of the dotfiles.git repository.
WORKING_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Function to check if a file should be excluded
is_excluded() {
    local filename="$1"
    for excluded in ${EXCLUDED_FILES}; do
        if [[ "${filename}" == "${excluded}" ]]; then
            return 0
        fi
    done
    return 1
}

# Enable dotglob to include hidden files in glob pattern
shopt -s dotglob

# Initialize arrays for tracking issues
WRONG_LINKS=()
EXISTING_LINKS=()

for item in "${WORKING_DIR}"/*; do
    LINK_NAME=$(basename "${item}")
    
    # Skip excluded files
    if is_excluded "${LINK_NAME}"; then
        continue
    fi
    # Set the path of the links filename.
    LINK_DEST_PATH="${HOME}/${LINK_NAME}"

    # Check wether the link already exists.
    if [[ -L "${LINK_DEST_PATH}" ]]
    then
        # The link exists.
        # Check if the links destination is correct.
        if [[ "$(readlink "${LINK_DEST_PATH}")" != "${WORKING_DIR}/${LINK_NAME}" ]]
        then
            # The links destination is wrong. Add it to the list.
            WRONG_LINKS+=("$(readlink "${LINK_DEST_PATH}") != ${WORKING_DIR}/${LINK_NAME}")
        fi
    else
        # The linkd does not exists in the home directory.
        # Check if there is a file or directory with the same name.
        if [[ -e "${LINK_DEST_PATH}" ]]
        then
            # There is already a file or directory with the same name.
            EXISTING_LINKS+=("${LINK_DEST_PATH}")
        else
            # Creating a link in the home directory to the correct file in the dotfiles repository.
            echo "Linking ${WORKING_DIR}/${LINK_NAME} to ${LINK_DEST_PATH}"
            ln -s "${WORKING_DIR}/${LINK_NAME}" "${LINK_DEST_PATH}"
        fi 
    fi
done

# Ask if programs should be installed
checkPrograms

# Print out a list of exisiting links but with wrong destination.
if [[ ${#WRONG_LINKS[@]} -gt 0 ]]
then
    echo -e "\n\n\e[31mThe following links exists but point to a wrong location"
    echo -e "Please remove or fix them\e[0m"
    printf '%s\n' "${WRONG_LINKS[@]}"
fi

# Print out a list of existing files or directories with the same name.
if [[ ${#EXISTING_LINKS[@]} -gt 0 ]]
then
    echo -e "\n\n\e[31mThe following files or directories alredy exists\e[0m"
    printf '%s\n' "${EXISTING_LINKS[@]}"
fi


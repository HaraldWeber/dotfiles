#!/bin/bash

# From https://stackoverflow.com/questions/1537956/bash-limit-the-number-of-concurrent-jobs
# A function to limit the number of background jobs

# Example:
# for x in $(seq 1 100); do     # 100 things we want to put into the background.
#     max_bg_procs 5            # Define the limit. See below.
#     your_intensive_job &
# done

function max_bg_procs {
    if [[ $# -eq 0 ]] ; then
            echo "Usage: max_bg_procs NUM_PROCS.  Will wait until the number of background (&)"
            echo "           bash processes (as determined by 'jobs -pr') falls below NUM_PROCS"
            return
    fi
    local max_number=$((0 + ${1:-0}))
    while true; do
            local current_number=$(jobs -pr | wc -l)
            if [[ $current_number -lt $max_number ]]; then
                    break
            fi
            sleep 1
    done
}

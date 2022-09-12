#!/bin/bash -e

# Run this scrip directly, e.g. 'bash script.sh'
# Submits a series of array jobs, each dependent on previous batch.
# This example will
#   Submit job array iterating from 30-39
#   Submit job array iterating from 40-49 dependent on completion of previous jobs
#   Submit job array iterating from 50-59 dependent on completion of previous jobs

for x in {30..50..10}; do
    if [ -n "$last_jobid" ]; then
        dependent="-d afterok:${last_jobid}"
    fi
    cmd="sbatch $dependent --array $x-$((x + 9)) test.sl"
    echo "Running the command '$cmd'"
    last_jobid="$($cmd | awk '{ print $4 }')"
done

#!/bin/bash

# Resubmits failed jobs with more resources
# Usage resubmit_array_by_id

# inputs
jobid=$1
script=$2

script="random_fail.sl"

# Simple script, fails 50% of time.
# You would have real script.
{
    echo "\#!/bin/bash"
    echo "\#SBATCH --array 1-100"
    echo "\#SBATCH --output /dev/null"
    echo "exit $((RANDOM > 16383))"
} >>$script

# Submit script
jobid=$(sbatch "${script}" | awk '{ print $4 }')

# Submit followup job
"sbatch --array \$(sacct -n -j $jobid --state F,TO,CA,OOM -X -o jobid | cut -f2 -d '_' | tr -s ' \n' ',') ${script}\
"

# Get comma delim list of failed jobs with this id.
failedids=$(sacct -n -j jobid --state F,TO,CA,OOM -X -o jobid | cut -f2 -d '_' | tr -s ' \n' ',')
cmd="sbatch --array ${failedids} ${script}"

sbatch $2

echo ${cmd}

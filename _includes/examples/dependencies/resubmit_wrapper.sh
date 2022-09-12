#!/bin/bash

# Inputs
# Use first arg for target script.
jobscript=$1

# Submit target script to slurm and catch job id.
jobid=$(sbatch "${jobscript}" | awk '{ print $4 }')

# This 'resubmit_cmd' will resubmit failed jobs with 1G mem using the same script.
# Put any other resource changes you want in this cmd
# However we don't run this command yet, we are just saving it to a variable.
resubmit_cmd="\
sbatch \
    --mem 1G \
    --array \$(sacct -n -j ${jobid} --state F,TO,CA,OOM -X -o jobid | cut -f2 -d '_' | tr -s ' \n' ',')\
    ${jobscript}"

# Submit followup job to main job
# This job will only start if some jobs fail.
# It will run the 'resubmit_cmd'.
sbatch \
    --job-name "chaser" \
    --dependency "afternotok:${jobid}" \
    --wrap "${resubmit_cmd}"

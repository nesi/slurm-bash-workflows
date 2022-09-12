#!/bin/bash -e

# Runs an array, (first pass). Any fails will be run again.

# Bash me.
#===================================================#
JOB_SCRIPT="OOM_50per.sl" # Name of job to submit. (Singleton)

MEM_FIRST_PASS="1500"  # Mem for first run
MEM_SECOND_PASS="3000" # Mem for second run

ARRAY_FIRST_PASS="0-10"

RESUBMIT_ON="F" # F,OOM etc
#===================================================#

# Submit job and get ID
FIRST_PASS_JOBID=$(sbatch --array $ARRAY_FIRST_PASS --mem $MEM_FIRST_PASS $JOB_SCRIPT | awk '{ print $4 }')

# Submit chaser job with array of failed jobs
sbatch -o "/dev/null" -d "afternotok:$FIRST_PASS_JOBID" --wrap "sbatch --array \$(sacct -j $FIRST_PASS_JOBID -n -X --format="JobID" -s "$RESUBMIT_ON" | cut -d'_' -f2 | tr -s ' \\n' ',') $JOB_SCRIPT"

#!/bin/bash -e

#SBATCH --open-mode append
#SBATCH --output week_times.out
#SBATCH --array 0-167 
#This needs to be equal to combinations (in this case 7*24), and zero based.

# Define your dimensions in bash arrays.
arr_time=({00..23})
arr_day=("Mon" "Tue" "Wed" "Thur" "Fri" "Sat" "Sun") 

# Index the bash arrays based on the SLURM_ARRAY_TASK)
n_time=${arr_time[$(($SLURM_ARRAY_TASK_ID%${#arr_time[@]}))]} 
# '%' for finding remainder.
n_day=${arr_day[$(($SLURM_ARRAY_TASK_ID/${#arr_time[@]}))]}
echo "$n_day $n_time:00"

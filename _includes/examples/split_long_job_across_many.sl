#!/bin/bash

#SBATCH --time      00:10:00
#SBATCH --job-name  "job"

# 'input_file' has many lines of data, each line must be proccessed serially.

# batchsize is how many lines will be proccessed for this job.
batch_size=1
input_file="/home/cwal219/project/ticket_categories/testloop/data_file.txt"

# Read last line from file, if doesn't exist be "0"
last_line="$(cat .last || echo 0)"
input_length="$(cat ${input_file} | wc -l)"

# If not last job.
# Submit this same script again, with this job as a dependency.
if ((last_line + batch_size < input_length)); then
    sbatch -d "afterok:$SLURM_JOB_ID" "$0"
fi

while read -r t dt; do
    echo -e "t=$t\ndt=$dt" >"${input_file}"
    echo "mapdl -i "${input_file}""
    # Incriment and write.
    echo $((last_line++)) >.last
done < <(tail -n +${last_line} ${input_file} | head -n ${batch_size}) #Get from 'last_line' to 'last_line + batchsize'
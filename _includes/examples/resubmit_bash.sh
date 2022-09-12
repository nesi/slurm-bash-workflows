#!/bin/bash
if [[ $# -lt 1 ]]; then
    echo "No file given."
    exit 1
fi

cmd="sbatch \
--time 00:15:00 \
--job-name resumbit \
--array 1-$(wc -l $1 | cut -f1 -d ' ') \
--wrap=\"\$(sed \"\${SLURM_ARRAY_TASK_ID}q;d\" $1)\""

echo ${cmd}

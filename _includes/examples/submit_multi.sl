#!/bin/bash

#SBATCH --job-name          Fluent-130
#SBATCH --licenses          aa_r_hpc@uoa_foe:1,aa_r@uoa_foe:64
#SBATCH --time              00:00:10
#SBATCH --nodes             1
#SBATCH --output            multi-output.out  # Put all outputs in same file
#SBATCH --open-mode         append            # Stop outputs from overwriting.
#SBATCH --mail-user         your.email@email.com
#SBATCH --mail-type         TIME_LIMIT_90     # Sends you an email if job reaches 90% time. (Useful if it might need extending)
module load ANSYS/2020R2

JOURNAL_FILE="$1"   # Set first arg to var
if (( $#>1 ));then # If more than 1 arg
    shift               # Remove
    sbatch --dependency afterok:$SLURM_JOB_ID "$0" $@   # Submit with dependency as self.
fi

echo "mambo number  $JOURNAL_FILE"
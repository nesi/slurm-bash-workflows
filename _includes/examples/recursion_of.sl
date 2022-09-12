#!/bin/bash -e

#SBATCH --job-name=0018-60M-3D
##SBATCH --account=uoa03308
##SBATCH --time=77:10:00
##SBATCH --ntasks=216
##SBATCH --mem-per-cpu=500
#SBATCH --output=%x-%j.out
#SBATCH --open-mode=append # This will make sure you can keep writing to the same output file.

this_script="/home/cwal219/slurm_templates/recursion_OF.sl"
last_step=1

echo "Step ${step:=0}"

# Decompose if needed.
if (( $(echo processor* | wc -w) != SLURM_NTASKS ));then
    decomposePar -force
fi

# Insert code that needs to be run between steps here
# Modify controlDict or whatever 

# Will submit _this_ script again, but will only start once this job finishes
# e.g. The next job will have the entire runtime of this job to get though the queue.
if (( step<last_step ));then
    export step=$((step+1))
    sbatch -d afterany:${SLURM_JOB_ID} $this_script
fi
module load OpenFOAM/v1906-gimkl-2018b
source ${FOAM_BASH}

#srun rhoPimpleFoam -parallel
#!/bin/bash
#======================================================#
# Description:  Starts a three stage workflow.
#               Pre - Preproccess and split into 3D grid.
#               Array - Submit job array for each partition.
#               Post - Re-assemble array.
#======================================================#
# Enviroment inerited by children, modules can be loaded here.
module load Python

# All stdout and stderr go here.
output_logs="/nesi/project/uoa02834/output_logs"
mkdir -p "$output_logs"

# Size of matrix ( x y z )
matrix_dimensions=( 2 4 100 ) 
path="/nesi/project/uoa02834/deconv-music"

#======================================================#
# Preproccess
#======================================================#
# Submits straight away, put whatever code is neccicery to run before parrallel element.

# Assuming 'pre' called with arguments 'x' 'y' 'z' path
pre_sbatch="--mem 1500 --time 00:20:00 --output $output_logs/pre.out \
--wrap \"python pre.py $matrix_dimensions $path\""
# Submit and get job id of 'pre'
pre_jobid=$(eval "sbatch ${pre_sbatch}" | awk '{ print $4 }')

#======================================================#
# Array
#======================================================#
# Submits on completion of 'pre'

# Assuming 'array' called with arguments 'x' 'y' 'z' path
array_sbatch="--dependency afterok:$pre_jobid --mem=1500 --time 00:20:00 --output $output_logs/array%x.out \
--array 0-$(( matrix_dimensions[0] * matrix_dimensions[1] * matrix_dimensions[2] - 1 ))  --wrap \"\
z=\$\(\(i/$((matrix_dimensions[1]*matrix_dimensions[0]))\)\);\
y=\$\(\(\(i-z*$((matrix_dimensions[1]*matrix_dimensions[0]))\)/${matrix_dimensions[0]}\)\);\
x=\$\(\(\(i-z*$((matrix_dimensions[1]*matrix_dimensions[0]))\)-\(y*${matrix_dimensions[0]}\)\)\);\
python array.py \$x \$y \$z $path\""

# Submit and get job id of 'array'
array_jobid=$(eval "sbatch ${array_sbatch}" | awk '{ print $4 }')

#======================================================#
# Postproccess
#======================================================#

post_sbatch="--dependency afterok:$array_jobid --mem 1500 --time 00:10:00 --output $output_logs/post.out \
--wrap \"python post.py \$x \$y \$z $path\""
eval "sbatch $post_sbatch"

#!/bin/bash -e

#SBATCH --job-name=recusion
#SBATCH --time=00:02:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100
#SBATCH --hint=nomultithread

maxIterations=3

if [[ -z "${CURRENT_ITERATION}" ]]
then
	export CURRENT_ITERATION=0
else
	export CURRENT_ITERATION=$((CURRENT_ITERATION+1))
	echo "Iteration ${CURRENT_ITERATION}/${maxIterations}"
	if [[ $CURRENT_ITERATION -gt $maxIterations ]]
	then
		echo "Max iterations hit"
		exit 0
	fi
fi

echo "Looking for data in output"

if [ -e output/data.txt ]
then
	echo "file exists" 
	runCount=$(sed 's/[^0-9]*//g' output/data.txt)
	echo "this is the ${runCount} run of this job"
	echo "Doing job stuff"
	echo "Writing job output"
	
	echo "This is run number [$(($runCount + 1))]" > output/data.txt
	
	echo "Having a nap"
	sleep 20

	#sbatch self
	echo "Calling next job"
	sbatch /$0
else
	echo "file doesn't exist"
	echo "Ending Chain"
	exit
fi

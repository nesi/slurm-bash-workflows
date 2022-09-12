#!/bin/bash -e
#Location of files to be validated.
outputDir="/nesi/project/uoa00629/Final19/Outputs/"

echo "Validating Files...."

#Range of expected file size.In bytes.
minSize=10000
maxSize=60000

#Number range of jobs to check
firstIndex=1
lastIndex=1000



dependant=$(sbatch ${ARRAY_JOB})


#What to do if missing file is found.
onMissing(){

echo "Submitting re-run of job ${1}"
batchFile=Rerun_Job_${1}.in
cat <<EOF > $batchFile

#!/bin/bash

#SBATCH --job-name=HAMED_CFD_RERUN_${1}
#SBATCH --account=uoa00629
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=1500
#SBATCH --licenses=ansys_hpc:0
#SBATCH --mail-type ALL
#SBATCH --mail-user habd942@aucklanduni.ac.nz
#SBATCH --output=/nesi/nobackup/uoa00629/Errors/Job_${1}_rerun.slm

output="./"
input="/nesi/nobackup/uoa00629/case_files"
temp="/nesi/nobackup/uoa00629/.tmp/"

#Loads ANSYS
module load ANSYS/18.1 

mkdir -p ${temp}${SLURM_JOBID}_${1}
cd ${temp}${SLURM_JOBID}_${1}
export TMPDIR=.

#Create new journal file from task ID
JOURNAL_FILE=Job_${1}.in

#Pipe in text to newly created file
cat <<EOF2 > $JOURNAL_FILE

rc ${input}Job_${1}.cas
/solve/iterate 300
exit yes
EOF2

#Start a fluent job using journal file we just made.
fluent -v3ddp -g -i Job_${1}.in

#Move or copy outputs to wherever you want.

ls -la
echo ${output}Job_${1}.out

mv -v Job.out ${output}Job_${1}.out
rm -r ${temp}${SLURM_JOB_NAME}_${1}
ls ${output}Job_${1}.out

EOF

#sbatch ${batchFile}



} 

for (( n=${firstIndex}; n<=${lastIndex}; n++ ))
do

#Specify naming scheme of files. Where ${n} will iterate across all indices.
filename="Job_${n}.out" 

if [ ! -e ${outputDir}${filename} ]; then

    echo "${filename} does not exist!"
    onMissing ${n}

elif [ $(wc -c <"${outputDir}${filename}") -le $minSize ]; then

    echo "${filename} is too small! ($(wc -c < ${outputDir}${filename}) bytes)"
    onMissing ${n}

elif [ $(wc -c <"${outputDir}${filename}") -ge $maxSize ]; then

    echo "${filename} is too big! ($(wc -c < ${outputDir}${filename}) bytes)" 
    onMissing ${n}

fi

done
echo "Done!"
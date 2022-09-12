#!/bin/bash

SETMEM=6000                                                         #Mem per real core
PREFIX="MAPDL"                                                        #Start of all job name.
CASE="V19cg-2"

ROOT="/nesi/project/nesi99999/Callum/profs/MAPDL/"
INPUTS="${ROOT}${CASE}"
OUTPUTS="${INPUTS}/runs/"


submitJob () {

OUT_STATEMENT="Submitting job "
dir_name="${PREFIX}_${CASE}_T${TASKS}"

MEMPERCPU=3000
CPUSPERTASK=${TASKS}
HINT='nomultithread'
dir_name="${dir_name}_Hoff_${4}"    


nodes=$((($i / 36) + ($i % 36 > 0)))

cd ${OUTPUTS}
#If directory of this name doesn't already exist.
if [ ! -d "${dir_name}" ]; then      
    mkdir ${dir_name}
    cd ${dir_name}

    cp -v "${INPUTS}/V19cg-1geom.db" .
    cp -v "${INPUTS}/V19cg-1.dat" .
    
    tempfile=.main$((tempnam)).sl

#======================================================#
cat <<mainEOF > ${tempfile}
#!/bin/bash -e

#=================================================#
#SBATCH --time			    01:00:00
#SBATCH --job-name		    ${dir_name}
#SBATCH --output		    %x.output
#SBATCH --ntasks            ${1}
#SBATCH --nodes             2
#SBATCH --cpus-per-task	    ${CPUSPERTASK}
#SBATCH --mem-per-cpu       ${MEMPERCPU}
#SBATCH --profile           ALL
#SBATCH --hint              ${HINT}
#=================================================#
module load ANSYS/18.1
#module load ANSYS/

#export TEMP="./"

cat \$0
env

input=""


mapdl -b -dis -np ${TASKS}" -i "${INPUT}/${CASE}.dat"
mainEOF

    #Submit job and pipe job ID to variable.
    chasingJobID=$(sbatch ${tempfile} | awk '{ print $4 }')


if [ "${6}" = "on" ]; then
    tempfile2=.slurm$((tempnam)).sl
    echo "Submitting Job ${chasingJobID}..."

cat <<chaserEOF > ${tempfile2}
#!/bin/bash

#=================================================#
#SBATCH --time			    00:01:00
#SBATCH --job-name		    ${dir_name}_chaser
#SBATCH --output		    /dev/null
#SBATCH --dependency        afterok:${chasingJobID}?afternotok:${chasingJobID}
#=================================================#

sacct -j "${chasingJobID}" >> *.output
sh5util -S -j ${chasingJobID} -o ./profile.h5
chaserEOF
    sbatch ${tempfile2}
fi

else
    echo "${dir_name} already exists, skipping..."
fi

}

submitJob 16 2 "off" "big2n" " -dis -np \${SLURM_NTASKS}" "off" 
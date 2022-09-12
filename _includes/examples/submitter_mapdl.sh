#!/bin/bash
INPUTS="/nesi/project/nesi99999/Callum/profs/MAPDL/V19cg-1"
OUTPUTS="${INPUTS}/runs/M8"
SETMEM=6000                                                         #Mem per real core
PREFIX="MAPDL"                                                        #Start of all job name.


submitJob () {

OUT_STATEMENT="Submitting job "
dir_name="${PREFIX}-C${2}_T${1}"
#If hyperthreading on
if [ "${3}" = "on" ]; then
    MEMPERCPU=$((${SETMEM}/2))
    CPUSPERTASK=${2}
    HINT='multithread'
    dir_name="${dir_name}_Hoff_${4}"
    OUT_STATEMENT="${dir_name}_Hoff_${4}_${5}"
else
    MEMPERCPU=3000
    CPUSPERTASK=$((${2}/2))
    HINT='nomultithread'
    dir_name="${dir_name}_Hoff_${4}"    
fi

echo "Submitting job ${dir_name} with ${2} CPUs/Task and ${1} tasks, hyperthreading ${3}, with ${5}"    
    
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

input="/nesi/project/nesi99999/Callum/profs/MAPDL/V19cg-1/V19cg-1.dat"


mapdl -b ${5} -i \${input}
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


submitJob 1 2 "off" "NopartNodisLocal" " " "off"
# Number of machines requested            :    1
# Total number of cores available         :   80
# Number of physical cores available      :   40
# Number of processes requested           :    1
# Number of threads per process requested :    2
# Total number of cores requested         :    2 (Shared Memory Parallel)  

# 305200       MAPDL-C2_T1_Hoff_NopartNodisL+   01:00:00 May 14 15:08 May 14 15:08   00:23:09  44:42.144 80        3000Mc             COMPLETED        nid00157
# 305200.batch                          batch            May 14 15:08 May 14 15:08   00:23:09  44:42.144 40  1     3000Mc  10890360K  COMPLETED        nid00157
# 305200.exte+                         extern            May 14 15:08 May 14 15:08   00:23:09   00:00:00 80  1     3000Mc      1348K  COMPLETED        nid00157

submitJob 1 32 "off" "NopartNodisLocal" " " "off" 

# Number of machines requested            :    1
# Total number of cores available         :   80
# Number of physical cores available      :   40
# Number of processes requested           :    1
# Number of threads per process requested :    2
# Total number of cores requested         :    2 (Shared Memory Parallel)

# 305201       MAPDL-C32_T1_Hoff_NopartNodis+   01:00:00 May 14 15:08 May 14 15:08   00:23:10  44:53.472 80        3000Mc             COMPLETED        nid00497
# 305201.batch                          batch            May 14 15:08 May 14 15:08   00:23:10  44:53.472 40  1     3000Mc  11290356K  COMPLETED        nid00497
# 305201.exte+                         extern            May 14 15:08 May 14 15:08   00:23:10   00:00:00 80  1     3000Mc       748K  COMPLETED        nid00497

submitJob 16 2 "off" "NopartNodisLocal" " " "off"

# Number of machines requested            :    1
# Total number of cores available         :   80
# Number of physical cores available      :   40
# Number of processes requested           :    1
# Number of threads per process requested :    2
# Total number of cores requested         :    2 (Shared Memory Parallel)     

# 305202       MAPDL-C2_T16_Hoff_NopartNodis+   01:00:00 May 14 15:08 May 14 15:08   00:23:05  44:41.704 80        3000Mc             COMPLETED        nid00504
# 305202.batch                          batch            May 14 15:08 May 14 15:08   00:23:05  44:41.704 40  1     3000Mc  11290436K  COMPLETED        nid00504
# 305202.exte+                         extern            May 14 15:08 May 14 15:08   00:23:05   00:00:00 80  1     3000Mc       748K  COMPLETED        nid00504


submitJob 1 32 "off" "PartNodisLocal" " -np \${SLURM_CPUS_PER_TASK} " "off" 

# Number of machines requested            :    1
# Total number of cores available         :   80
# Number of physical cores available      :   40
# Number of processes requested           :    1
# Number of threads per process requested :   16
# Total number of cores requested         :   16 (Shared Memory Parallel)  

# 305224       MAPDL-C32_T1_Hoff_PartNodisDis   01:00:00 May 14 15:33 May 14 15:33   00:07:50   01:45:15 80        3000Mc             COMPLETED        nid00157
# 305224.batch                          batch            May 14 15:33 May 14 15:33   00:07:50   01:45:15 40  1     3000Mc  11652448K  COMPLETED        nid00157
# 305224.exte+                         extern            May 14 15:33 May 14 15:33   00:07:50   00:00:00 80  1     3000Mc      1348K  COMPLETED        nid00157


submitJob 1 32 "off" "SLPPartNodisLocal" " -np \${SLURM_CPUS_PER_TASK} " "off" 
#sbatch: Warning: can't run 1 processes on 2 nodes, setting nnodes to 1

# Number of machines requested            :    1
# Total number of cores available         :   80
# Number of physical cores available      :   40
# Number of processes requested           :    1
# Number of threads per process requested :   16
# Total number of cores requested         :   16 (Shared Memory Parallel)   

# 305243       MAPDL-C32_T1_Hoff_SLPPartNodi+   01:00:00 May 14 15:56 May 14 15:56   00:07:33   01:39:39 80        3000Mc             COMPLETED        nid00160
# 305243.batch                          batch            May 14 15:56 May 14 15:56   00:07:33   01:39:39 40  1     3000Mc  11815792K  COMPLETED        nid00160
# 305243.exte+                         extern            May 14 15:56 May 14 15:56   00:07:33   00:00:00 80  1     3000Mc       748K  COMPLETED        nid00160


submitJob 1 32 "off" "SPLPartDisLocal" "-dis -np \${SLURM_CPUS_PER_TASK} " "off" 
#sbatch: Warning: can't run 1 processes on 2 nodes, setting nnodes to 1
#srun: error: Unable to create step for job 305244: More processors requested than permitted


submitJob 16 2 "off" "SLPPartNodisDis" " -np \${SLURM_NTASKS} " "off" 

# Number of machines requested            :    1
# Total number of cores available         :   80
# Number of physical cores available      :   40
# Number of processes requested           :    1
# Number of threads per process requested :   16
# Total number of cores requested         :   16 (Shared Memory Parallel)  

# Number of machines requested            :    2
# Total number of cores available         :  144
# Number of physical cores available      :   72
# Number of processes requested           :   16
# Number of threads per process requested :    1
# Total number of cores requested         :   16 (Distributed Memory Parallel)               
# MPI Type: INTELMPI


# 305245       MAPDL-C2_T16_Hoff_SLPPartNodi+   01:00:00 May 14 15:56 May 14 15:56   00:07:35   01:41:00 160        3000Mc             COMPLETED  nid00[509-510]
# 305245.batch                          batch            May 14 15:56 May 14 15:56   00:07:35   01:41:00 40  1     3000Mc  11652360K  COMPLETED        nid00509
# 305245.exte+                         extern            May 14 15:56 May 14 15:56   00:07:35   00:00:00 160  2     3000Mc      1352K  COMPLETED  nid00[509-510]



submitJob 16 2 "off" "SPLPartDisDis" "-dis -np \${SLURM_NTASKS} " "off" 
#MPI FAIL

submitJob 16 2 "off" "CRAYPartDisDis" "-mpi=cray -dis -np \${SLURM_NTASKS} " "off" 
#NOCRAY

submitJob 16 2 "on" "mah2" " -dis -np \${SLURM_NTASKS} " "off" 
# Number of machines requested            :    5
# Total number of cores available         :  360
# Number of physical cores available      :  180
# Number of processes requested           :   16
# Number of threads per process requested :    1
# Total number of cores requested         :   16 (Distributed Memory Parallel)               
# MPI Type: INTELMPI
# MPI Version: Intel(R) MPI Library 5.1.3 for Linux* OS

submitJob 16 4 "on" "mah" " -dis -np \${SLURM_NTASKS} " "off" 

# Number of machines requested            :    8
# Total number of cores available         :  576
# Number of physical cores available      :  288
# Number of processes requested           :   16
# Number of threads per process requested :    1
# Total number of cores requested         :   16 (Distributed Memory Parallel)               
# MPI Type: INTELMPI
# MPI Version: Intel(R) MPI Library 5.1.3 for Linux* OS

submitJob 16 4 "on" "mah2np" " -dis -np \${SLURM_NTASKS} -np \${SLURM_CPUS_PER_TASK}" "off" 

# Number of machines requested            :    4
# Total number of cores available         :  288
# Number of physical cores available      :  144
# Number of processes requested           :    4
# Number of threads per process requested :    1
# Total number of cores requested         :    4 (Distributed Memory Parallel)               
# MPI Type: INTELMPI
# MPI Version: Intel(R) MPI Library 5.1.3 for Linux* OS

submitJob 4 2 "on" "mah2small" " -dis -np \${SLURM_NTASKS}" "off" 

# Number of machines requested            :    1
# Total number of cores available         :   72
# Number of physical cores available      :   36
# Number of processes requested           :    4
# Number of threads per process requested :    1
# Total number of cores requested         :    4 (Distributed Memory Parallel)               
# MPI Type: INTELMPI
# MPI Version: Intel(R) MPI Library 5.1.3 for Linux* OS

submitJob 16 2 "off" "big1n" " -dis -np \${SLURM_NTASKS}" "off" 

# Number of machines requested            :    1
# Total number of cores available         :   72
# Number of physical cores available      :   36
# Number of processes requested           :   16
# Number of threads per process requested :    1
# Total number of cores requested         :   16 (Distributed Memory Parallel)               
# MPI Type: INTELMPI
# MPI Version: Intel(R) MPI Library 5.1.3 for Linux* OS

submitJob 16 2 "off" "big2n" " -dis -np \${SLURM_NTASKS}" "off" 
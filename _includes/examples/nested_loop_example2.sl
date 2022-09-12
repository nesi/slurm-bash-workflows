#!/bin/bash
#======================================================#
#
#======================================================#
root_path="/nesi/nobackup/uoa00539/"

#Location of scripts and EEGlab
run_path="${root_path}Testing/"

#WORKERS=20
DOWNSAMPLE_RATE=1
#======================================================#
submitJob () {

dir_name="${PREFIX}-C${2}_T${1}"

o_type=${1}
case ${o_type} in
"RS")

    #Location of input raw file
    input_path=${root_path}AllRAWfiles/Pilots/PP00${participant}00${sequence}rs.RAW

    #Directory for outputs
    output_path=${root_path}Outputs/

    #name of script
    script_name="STEP_1_Processing_RS_v3"


;;
"RS_processed")



;;
"RS_BCST_RMET")




;;
"RS_BCST_RMET_processed")



;;
*)

    echo "No script type specified!"
    exit 1
;;
esac

job_name="P${participant}_${input}_${o_type}"

if [ -e ${input_path} ]
then
    echo "ok"
else
    echo "No input at path specified!"
    exit 1
fi
    
#If directory of this name doesn't already exist.
mkdir -p ${output_path}
cd ${output_path}

    tempfile=.main$((tempnam)).sl

#======================================================#
cat <<mainEOF > ${tempfile}
#!/bin/bash -e

#=================================================#
#SBATCH --time			    01:00:00
#SBATCH --job-name		    ${job_name}
#SBATCH --output		    %x.output
#SBATCH --cpus-per-task	    4
#SBATCH --mem-per-cpu       2G
#=================================================#
# Avoid possible future version issues
module load MATLAB/2018b

cd ${run_path}

# If running serial '-nojvm' can be added
matlab -nodisplay -nosplash -r "downsampleRate=${DOWNSAMPLE_RATE};setWorkers='${WORKERS}';inputPath='${input_path}';${script_name}; exit"
mainEOF

#Submit job and pipe job ID to variable.
job_id=$(sbatch ${tempfile} | awk '{ print $4 }')

echo "Submitting job ${job_name} (${job_id})\nDownsample rate:${DOWNSAMPLE_RATE}\nParticipants:${participant}\nInput:${input_path}\nOutput:${output_path}${output_name}\nUsing ${o_type}"

}


arr_participants={1..29}
arr_sequence=( 1 2 3 )


for participant in "${arr_participants[@]}"; do

    for sequence in "${arr_sequence[@]}"; do

        submitJob "RS"

        submitJob "RS_processed"

        submitJob "RS_BCST_RMET"

        submitJob "RS_BCST_RMET_processed"

    done

done

#!/bin/bash

# ===
# Use: Script will submit same job recursivly in all bottom level directories.
# ===

# Name of script to write.
scriptname="submit.sl"

# If given a path, use that. Else use current directory.
if [[ $1 ]];then
    # Check path is real
    ls "$1" > /dev/null || exit
    root=$(realpath "$1")
else
    root=$PWD
fi

#Loops though every bottom level directory in path given.
for jobpath in $(find $root -type d -links 2);do
    # Create a readable name from path
    name_of_job="$(echo "$jobpath" | tr -d '.' | tr '\/' '_')"
    
    # Move into that directory
    cd "$jobpath" || exit
#======================================================#
# INSERT SCRIPT TO REPEAT BELOW
#======================================================#   
cat << EOF > ${scriptname} 
#!/bin/bash -e

#SBATCH --cpus-per-task     4
#SBATCH --mem-per-cpu       1500
#SBATCH --time              02:00:00
#SBATCH --job-name          ${name_of_job}
#SBATCH --output            %x.out

module load Delft3D/66341-intel-2020a

srun d_hydro config_flow2d3d.xml
EOF
#======================================================#

    # Submit job
    sbatch $scriptname > /dev/null && printf "Starting '$name_of_job' in '$jobpath'\n"
    # Pause to avoid spamming database.
    sleep 1
    # Move back up to root directory
    cd "../"
done

echo "done!"


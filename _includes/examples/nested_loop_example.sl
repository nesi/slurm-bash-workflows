#!/bin/bash

runs=3
steps=6

for (( i=1; i<=$runs; i++ ))
do
	for (( n=1; n<=$steps; n++ ))
	do
	
cat <<EOF > inputs/training_procedure_step${n}_${i}.m

disp('Hello there');
fileID = fopen('${n}_${i}.txt','w');
fprintf(fileID, 'General Kenobi. You are a bold one.');
fclose(fileID);

EOF
		echo "File /training_procedure_step${n}_${i}.m created"
	done
  
done





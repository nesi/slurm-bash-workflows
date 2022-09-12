def submitJob():

    # whatever you usually do, except capture the job id.

    job_id=subprocess.check_output(' '.join(["sbatch", script_name]), shell=True).split()[-1]


def getArrayStates(job_id):
    """
    Parse the results of sacct into a dictionary of task ids keyed by state.
    """
    state_task_ids = {}
    sacct_output=subprocess.check_output(' '.join(["sacct", "-n", "-j", str(job_id), "-X", "-P", "-o", "jobid,state" ]), shell=True)
    for job_state in sacct_output.strip().split("\n"):
        [jobid_taskid, state]=job_state.strip().split("|")
        [jobid, taskid]=jobid_taskid.split("_")
        if state not in state_task_ids: state_task_ids[state]=[]
        state_task_ids[state].append(taskid)
    return state_task_ids

def waitOnArray(job_id):

    poll_period = 30

    while True:
        time.sleep(poll_period)
        array_state = getArrayStates(job_id)

        # Insert cool progress bar here.
        print(array_state)

        # If any jobs in queue just keep waiting.
        if "PENDING" in array_state: continue

        # If all jobs are 'COMPLETED' return from function.
        elif "COMPLETED" in array_state and len(array_state) == 1: break
        
        # If some jobs failed, resubmit them.
        else:
            array_state.pop('COMPLETED', None) # Remove completed jobs from array.
            ids_to_resubmit=[]
            for ids in array_state.values():
                ids_to_resubmit += ids
            array_argument = "--array " + ",".join(ids_to_resubmit)


            # Do whatever you did in the first place to submit a job, except add 
            job_id=subprocess.check_output((' '.join(["sbatch", array_argument, script_name]), shell=True)).split()[-1]
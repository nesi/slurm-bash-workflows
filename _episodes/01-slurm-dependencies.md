---
title: "Slurm Dependencies"
teaching: 15
exercises: 5
questions:
- "What is a Slurm job dependency?"
keypoints:
- "High Performance Computing (HPC) typically involves connecting to large
  computing system in another place."
---

Slurm dependencies allow you to submit a job into the queue, with instructions not to begin until certain criteria are fulfilled, usually the state of another job.

## Parameters

Job dependencies can be utilised by using the Slurm keyword `--dependency` and arguments `[condition]:[jobid]`, a full list of which can be found in the [sbatch documentation](https://slurm.schedmd.com/sbatch.html#OPT_dependency).

Some examples

| --------- | --------- |
| `--dependency  after:jobid` |	This job will not start unless `jobid` has _started_. |
| `--dependency  afterok:jobid`	| This job will not start unless `jobid` has _completed_ with a _zero_ exit status. |
| `--dependency  afternotok:jobid` | This job will not start unless `jobid` has _completed_ with a _non-zero_ exit status. |
| `--dependency  afterany:jobid` | This job will not start unless `jobid` has completed. |
| `--dependency  aftercorr:jobid` | Tasks in this job array will not start until the _corresponding_ task id has completed succesfully |
| `--dependency  singleton` | This job will not start unless all jobs _sharing this name_ (submitted by me) have finished.

If you need your job to depend on the state of multiple jobs, more can be added to a condition using `:` as a delimeter.

`--dependency  afterok:jobid1:jobid2`	This job will not start unless `jobid1` _and_ `jobid2` has _started_.

Or, if multiple conditions need to be used, this can be done using a `,` delimeter for a logical-AND or a `?`  for logical-OR.

`--dependency  afterok:jobid1,after:jobid1` This job will not start unless `jobid1` completed succesfully _and_ `jobid2` has started.
`--dependency  afterok:jobid1?afterany:jobid1` This job will not start unless `jobid1` completed succesfully _or_ `jobid2` has completed.

## -d
> `-d` is the short form of `--dependency`. Note the single dash instead of two.
{: .callout}

> ## Job dependency excersise.
> Dini has the following output from `sacct`.
> > JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
> > ------------ ---------- ---------- ---------- ---------- ---------- -------- 
> > 29880010         kakapo      large  nesi99999          2  COMPLETED      0:0 
> > 29880012         takahe      large  nesi99999          2  RUNNING      0:0 
> > 29880012            moa      large  nesi99999          2  PENDING      0:0 
> > 29880013    stickinsect      large  nesi99999          2  FAILED      0:0 
> > 29880015_1     seasnail      large  nesi99999          2  COMPLETED      0:0 
> > 29880015_2     seasnail      large  nesi99999          2  RUNNING      0:0 
> {: .output}
> Based on this knowledge, which of the following dependencies would be able to run.
> 1. `--dependency  after:29880012`
> 2. `--dependency  afterok:kakapo`
> 3. `--dependency  singleton --name takahe`
> 4. `--dependency  afterok:29880013?after:29880010:29880012`
> 5. `--dependency  aftercorr:29880015 --array 1-10`
> > ## Solution
> > 1. Yes. job `29880012` has _started_.
> > 2. No. Jobs must be specified by their _job ID_
> > 3. No. There is still a job named `takahe` running.
> > 4. Yes. The first condition `afterok:29880013` is not fulfilled. But the second condition `after:29880010:29880012` is.
> > 5. Partially. One of the jobs in the job array (`SLURM_ARRAY_TASK_ID=1`) would be allowed to start as the _corresponding_ job from `29880015` has finished.
> {: .solution}
{: .challenge}

> ## Where Do Slurm Parameters go?
> Slurm parameters can be specified in a _Slurm Script_ following the `#SBATCH` token.  
> > #SBATCH --_key_   _value_
> {: .language-bash}
> Alternatively, parameters can be provided on the command line when submitting a Slurm job.
> > sbatch --_key_ _value_ _script.sl_
> > {: .language-bash}
> Parameters given on the command line, overrule parameters inside the script.
{: .callout}

## Getting job IDs

You can catch the ID of a job you have just submitted using.
```
jobid=$(sbatch partOne.sl | awk '{ print $4 }')
sbatch -d afterok:${jobid} partTwo.sl
```

Or, submit the second job from within the first.

Inside `partOne.sl`
> !#/bin/bash
> 
> #SBATCH --job-name stuff
>
> # Include this line right at the start, before you do any work.
> sbatch --dependency afterok:${SLURM_JOB_ID} partTwo.sl
>
> # Work goes here
{: .language-bash}

In both examples, `partTwo.sl` will run on the successful conclusion of `partOne.sl`.


## Building a Pipeline

```
lastjobid=$(sbatch partOne.sl | awk '{ print $4 }')
lastjobid=$(sbatch -d ${lastjobid} partTwo.sl | awk '{ print $4 }')
lastjobid=$(sbatch -d ${lastjobid} partThree.sl | awk '{ print $4 }')
sbatch -d ${lastjobid} partFour.sl
```

{% include links.md %}

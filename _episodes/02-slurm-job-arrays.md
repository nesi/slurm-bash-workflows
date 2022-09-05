---
title: "Slurm Job Arrays"
teaching: 15
exercises: 5
questions:
- "What is a Slurm job array?"
- "Why not just submit jobs in a loop?"
- "?"
keypoints:
- ""
---

The best way to submit many jobs in a responsible and easy to handle way is to use _Slurm Job arrays_.

# What is a Slurm Job Array

A job array differs from a regular Slurm job in that it has many child 'tasks', each of these tasks running the same script.

> JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
> ------------ ---------- ---------- ---------- ---------- ---------- -------- 
> 30082012_1         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_2         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_3         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_4         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_5         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_6         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_7         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_8         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_9         wrap      large  nesi99999          2     FAILED      1:0 
> 30082012_10        wrap      large  nesi99999          2     FAILED      1:0 
{: .output}

Note the jobID for all 10 jobs are the same, but include a "taskID".
By default, tasks in the same state will be folded into one line in `squeue`.


> ## Loop Submission
> 
> Wes is running a parametric sweep on NeSI, unfortunately no-one has told him about job arrays.
> Unfortunatly Wes knows a little bit of bash, and so runs the following command.
> > for i in {1..1000};do sbatch myScript.sl;done
> {: .language-bash}
> Why might this be a problem?
> > ## Solution
> >
> > * Difficult to manage: If the job needs to be cancelled you will have to retreive all of the seperate jobID's (or something like `scancel -u $USER`)
> > * Organisation: If more than one sweep is being run, it will not be obvious which jobs belong to what.
> > * Strain on Slurm: Could cause slowdowns or the database going down entirely.
> > * Expensive: Uses lots of accounting resources (lots of jobIDs, rows in databases etc...)
> > * Spammy: Will fill up job lists, skew statistics, etc.
> {: .solution}
{: .challenge}

## '--array' Parameter

A Slurm script can be made into a job array by including the `--array` parameter.

> #SBATCH --time    00:15:00
> #SBATCH --mem     2G
> #SBATCH --array   1-10
> #SBATCH --output  part%a.out
{: .language-bash}

Will cause the above job to run 10 times.
The resources specified are for each job individualy. e.g. Each job will get 2G of memory and 15 minutes walltime.
The token `%a` can be used in Slurm parameters and is subtituted for the taskID. e.g. Outputs will be `part1.out`,`part2.out`...

The array parameter accepts multiple formats.

> --array=1-5
{: .language-bash}
as `1`,`2`,`3`,`4`,`5`

> --array=3,5,7
{: .language-bash}
as `2`,`4`,`6`

> --array=2-6:2
{: .language-bash}
as `2`,`4`,`6`

A max number of concurrent jobs can also be specified using `%`
> --array=1-100%10
{: .language-bash}

e.g. Will submit 100 jobs, but no more than 10 will be allowed to run at once.



## Task ID variable




### scatter-gather workflow

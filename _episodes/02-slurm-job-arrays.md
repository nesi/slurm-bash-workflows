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

## What is a Slurm Job Array

A job array differs from a regular Slurm job in that it has many child 'tasks', each of these tasks running the same script.

```
 JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
 ------------ ---------- ---------- ---------- ---------- ---------- -------- 
 30082012_1         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_2         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_3         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_4         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_5         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_6         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_7         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_8         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_9         wrap      large  nesi99999          2     FAILED      1:0 
 30082012_10        wrap      large  nesi99999          2     FAILED      1:0 
```
{: .output}

Note the jobID for all 10 jobs are the same, but include a "taskID".
By default, tasks in the same state will be folded into one line in `squeue`.


> ## Loop Submission
> 
> Wes is running a parametric sweep on NeSI, no-one has told him about job arrays.
> Unfortunatly Wes knows a little bit of bash, and so runs the following command.
> ```
> for i in {1..1000};do sbatch myScript.sl;done
> ```
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

## Creating Job Arrays

A Slurm script can be made into a job array by including the `--array` parameter.

```
#SBATCH --time    00:15:00
#SBATCH --mem     2G
#SBATCH --array   1-10
```
{: .language-bash}

Will cause the above job to run 10 times.
The resources specified are for each job individualy. e.g. Each job will get 2G of memory and 15 minutes walltime.

The array parameter accepts multiple formats.

```
--array=1-5
```
{: .language-bash}
as `1`,`2`,`3`,`4`,`5`

```
--array=3,5,7
```
{: .language-bash}
as `2`,`4`,`6`

```
--array=2-6:2
```
{: .language-bash}
as `2`,`4`,`6`

A max number of concurrent jobs can also be specified using `%`
```
--array=1-100%10
```
{: .language-bash}

e.g. Will submit 100 jobs, but no more than 10 will be allowed to run at once.

> ## Loop Submission
> 
> Wesley is running a parametric sweep on NeSI.
> Unfortunatly Wes knows a little bit of bash, and so runs the following command.
> ```
> for i in {1..1000};do sbatch myScript.sl;done
> ```
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

## Task ID variable

Every job in the array will be launched identically, except for one enviroment variable `SLURM_ARRAY_TASK_ID`. This 'task id' is analogous to the index of a for loop and should be used for differentiating inputs. 

```
#!/bin/bash

#SBATCH --array=1-5

echo "Hello, I am task number ${SLURM_ARRAY_TASK_ID}."
```
{: .language-bash}


## Inputs

A couple of examples on how task id can be used.

> ## Scope
> The below examples all use logic at the level of the bash script. 
> If you are writing your own code, you might want to do your logic there, most languages will have a function you can use to access enviroment variables. for example in Python.  
> ```
> os.environ.get('SLURM_ARRAY_TASK_ID')
> ```
> {: .language-python}
{: .callout}

As an index to an array, useful if your inputs are non-numeric.
Most langauges use zero based arrays, so make sure that the `--array` parameter reflects this.

```
#SBATCH --array 0-6

inArray=("Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Violet")
input=${inArray[$SLURM_ARRAY_TASK_ID]}
```
{: .language-bash}

For selecting input files.
This requires that you have consistantly named data and the matching range in the slurm header.

```
input=inputs/mesh_${SLURM_ARRAY_TASK_ID}.stl
```
{: .language-bash}

As an index to an array of filenames. 

```
files=( inputs/*.dat )
input=${files[SLURM_ARRAY_TASK_ID]}
```
{: .language-bash}

As a seed for a pseudo-random number.

<ul class="nav nav-tabs nav-justified" role="tablist">
<li role="presentation"><a data-os="rand-python" href="#rand-python" aria-controls="rand-python" role="tab"
data-toggle="tab">Python</a></li>
<li role="presentation" class="active"><a data-os="rand-r" href="#rand-r" aria-controls="rand-r"
role="tab" data-toggle="tab">R</a></li>
<li role="presentation"><a data-os="rand-matlab" href="#rand-matlab" aria-controls="rand-matlab" role="tab"
data-toggle="tab">MATLAB</a></li>
</ul>

<div class="tab-content">
  
<article role="tabpanel" class="tab-pane" id="rand-python">
  
```
task_id = os.environ.get("SLURM_ARRAY_TASK_ID")
random.seed(task_id)
```
{: .language-python}
  
</article>
<article role="tabpanel" class="tab-pane active" id="rand-r">
  
```
task_id = as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
set.seed(task_id)
```
{: .language-r}
  
</article>

<article role="tabpanel" class="tab-pane" id="rand-matlab">
  
```
task_id = str2num(getenv('SLURM_ARRAY_TASK_ID'))
rng(task_id)
```
{: .language-matlab}

</article>
</div>
</div>

Using a seed is important, otherwise multiple jobs may receive the same pseudo-random numbers.

## Outputs

> ## Loop Submission
> 
> Matthew is using a job array as an intermediatary step in a pipeline. Both the inputs and outputs must match a specific naming convention.
>  
> ```
> #!/bin/bash
>
> #SBATCH --mem 2G
> #SBATCH --time 01:00:00
> #SBATCH --array 1-100
> #SBATCH --output stage3/partition${SLURM_ARRAY_TASK_ID}.log
> 
> input_file="stage2/partition${SLURM_ARRAY_TASK_ID}.stl
> {: .language-bash}
> Where will Matthew need to look to find the output of the 17th job?
> > ## Solution
> >
> > The output of _all_ one-hundred jobs will be written to a file named `stage3/partition.log`, 
> > in practice this means only the last job to finish will be recorded there. 
> > This is because `$SLURM_ARRAY_TASK_ID` is set in the enviroment of the job being run, 
> > where as the Slurm header is read when and where `sbatch` is called.  
> > So unless `SLURM_ARRAY_TASK_ID` is set to something in the submitters enviroment the value in the header will be empty.

> {: .solution}
{: .challenge}

### Tokens

Properties in the Slurm header can be set dynamically through the use of tokens. The important one to us here is `%a` which will evaluate to the Task ID

For example `--output part%a.out` will lead to outputs named, `part1.out`,`part2.out` etc.
More info about the other tokens can be found in the [Slurm Documentation](https://slurm.schedmd.com/sbatch.html#SECTION_%3CB%3Efilename-pattern%3C/B%3E).

```
--opem-mode append
```

{% include links.md %}

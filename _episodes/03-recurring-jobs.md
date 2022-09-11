---
title: "Recurring Jobs"
teaching: 15
exercises: 5
questions:
- "How can repeat jobs be scheduled?"
keypoints:
- "Scrontabs (Slurm-Crontab) can be used to run slurm jobs at regular interviews.
- "Scrontabs use `#SCRON` instead of `#SBATCH`"
---
Note: This lesson was mostly copied from [YCRC](https://docs.ycrc.yale.edu/), 

## Scrontab

You can use `scrontab` to schedule recurring jobs. It uses a syntax similar to [`crontab`](https://man7.org/linux/man-pages/man5/crontab.5.html), a [standard Unix/Linux utility](https://en.wikipedia.org/wiki/Cron) for running programs at specified intervals. 

> ## "`scrontab` vs `crontab`"
> If you are familiar with `crontab`, there are some important differences to note:
> - The scheduled times for `scrontab` indicate when your job is *eligible* to start. They are not start times like a traditional Cron jobs.
> - Jobs managed with `scrontab` won't start if an earlier iteration of the same job is still running. Cron will happily run multiple copies of a job at the same time.
> - You have one scrontab file for the entire cluster, unlike crontabs which are stored locally on each computer.
{ .callout}

## Set Up Your `scrontab`

### Edit Your `scrontab`

Run `scrontab -e` to edit your `scrontab` file.

Lines that start with `#SCRON` are treated like the beginning of a new batch job, and work like `#SBATCH` directives for batch jobs. Slurm will ignore `#SBATCH` directives in scripts you run as `scrontab` jobs. You can use most [common `sbatch` options](/clusters-at-yale/job-scheduling/#common-job-request-options) just as you would [using sbatch on the command line](https://slurm.schedmd.com/sbatch.html). The first line after your `SCRON` directives specifies the schedule for your job and the command to run. 


> ## homedir
> All of your `scrontab` jobs will start with your home directory as the working directory. You can change this with the `--chdir` slurm option.
>
{: .callout}


### Cron syntax

Crontab syntax is specified in five columns, to specify minutes, hours, days of the month, months, and days of the week. Especially at first you may find it easiest to use a helper application to generate your cron date fields, such as [crontab-generator](http://crontab-generator.org/) or [cronhub.io](https://crontab.cronhub.io/). You can also use the short-hand syntax `@hourly`, `@daily`, `@weekly`, `@monthly`, and `@yearly` instead of the five separate columns.

### What to Run

If you're running a script it must be marked as executable. Jobs handled by scrontab do not run in a full login shell, so if you have customized your `.bashrc` file you need to add:

``` 
source ~/.bashrc
```
{ .language-bash}

To your script to ensure that your environment is set up correctly.

> ## Directive
> `#SBATCH` directives in executed scripts will be ignored.  You must use `#SCRON` in the scrontab file instead.
{: .callout}

## JobID
> Your `scrontab` jobs will appear to have the same JobID every time they run until the next time you edit your `scrontab` file (they are being requeued). 
> This means that only the most recent job will be logged to the default output file. 
> If you want deeper history, you should redirect output in your scripts to filenames with something more unique in their names, like a date or timestamp, e.g.

```

python my_script.py > $(date +"%Y-%m-%d")_myjob_scrontab.out
```
{ .language-bash}


If you want to see slurm accounting of a job handled by scrontab, for example job `12345` run:

``` 
sacct --duplicates --jobs 12345
# or with short options
sacct -Dj 12345
```
{ .language-bash}


## Examples 

### Run a Daily Simulation

This example submits a 6-hour simulation eligible to start every day at 12:00 AM.

```
#SCRON --time 6:00:00
#SCRON --cpus-per-task 4
#SCRON --name "daily_sim"
#SCRON --chdir /home/netid/project
#SCRON -o my_simulations/%j-out.txt
@daily ./simulation_v2_final.sh
```
{ .language-bash}


### Run a Weekly Transfer Job

This example submits a transfer script eligible to start every Wednesday at 8:00 PM.

``` 
#SCRON --time 1:00:00
#SCRON --partition transfer
#SCRON --chdir /home/netid/project/to_transfer
#SCRON -o transfer_log_%j.txt
0 20 * * 3 ./rclone_commands.sh
```
{ .language-bash}


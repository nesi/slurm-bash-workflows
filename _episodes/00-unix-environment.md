
---
title: "Unix Enviroment"
teaching: 15
exercises: 5
questions:
- ""
keypoints:
- ""
---

## Shell

## Unix piping

Unix processes have a standard input stream (stdin) and a standard output stream (stdout). 

The pipe symbol ‘|’ can join multiple processes together into a very simple pipeline


Stolen from swc-bash.
![image](https://user-images.githubusercontent.com/35017184/188520960-1ce077e0-c354-4f2e-a9ef-be7e46bb6bc7.png)
The pipe symbol ‘|’ can join multiple processes together into a very simple pipeline

For more info see [episode 4 of shell-novice](https://swcarpentry.github.io/shell-novice/04-pipefilter/index.html)


## Script Readability

### One-Line Multi-lines

Any multiline commands can be written inline by substituting the newline with a `;`.

For example 

```sh
a=1
b=2
c=$((a + b))
echo ${c}
```

Can be written as

```sh
a=1; b=2; c=$((a + b)); echo ${c}
```

### Multi-line One-lines

A single line can be broken into multiple lines using `\`

For example.

```sh
abaqus interactive job=1_2mmThick_10mmCell input=../../1_2mmThick_10mmCell  verbose=2 cpus=12 domains=6 mp_mode=threads user=../../some_udf.c double=explicit gpus=1 >> output.log
```

Can be written as

```sh
abaqus interactive\
    job=1_2mmThick_10mmCell\
    input=../../1_2mmThick_10mmCell\
    verbose=2\
    cpus=12\
    domains=6\
    mp_mode=threads\
    user=../../some_udf.c\
    double=explicit\
    gpus=1\
    >> output.log
```

The above example uses indentation to indicate the broken lines are still part of the same command. The whitespace is _not ignored_ meaning the command will be interpreted as

```sh
abaqus interactive    job=1_2mmThick_10mmCell    input=../../1_2mmThick_10mmCell    verbose=2    cpus=12    domains=6    mp_mode=threads    user=../../some_udf.c    double=explicit    gpus=1    >> output.log
```
If the command being used is modified by whitespace, you will need to take this under consideration.

!!! warn
    The escaping `\` needs to be the last character before the newline (including whitespace). This can be a difficult typo to spot, if your editor has a setting to display whitespace characters, it is a good idea to enable this. 


## Enviroment variable

Talk about 

{% include links.md %}

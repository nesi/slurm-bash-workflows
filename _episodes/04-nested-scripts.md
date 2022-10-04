---
title: "A Better name"
teaching: 15
exercises: 5
questions:
- "When and "
keypoints:
- "Wrapper script"
---

## Wrapper scripts

A 'wrapper' is a script that supports the execution of some proccess. 
In this case, we are talking about a bash script wrapping a Slurm command.


Sometimes it can be useful to create a text file from inside your script.
If the file is one line, this can be done easily using `echo` and a redirect`

```
echo "Hello World" > my-new-file.txt
```

Will create the file `my-new-file.txt` with the contents `Hello World` (if the file already existed it's contents will be overwritten).

Creating a multiple line file can be done using this method also. 

```
echo "Line One" > my-new-file.txt
echo "Line Two" >> my-new-file.txt
echo "Line Three" >> my-new-file.txt
```
This can be simplified using a subshell
```
(
echo "Line One"
echo "Line Two"
echo "Line Three" 
) > my-new-file.txt
```
Alternatively the newline code `\n` can be used (`echo -e` or `printf` must be used to expand escape sequences).

```
echo -e "Line one\n Line Two\n Line Three" > my-new-file.txt
```

While all of these methods are OK to use, they can become unwealdy, or unreadable when creating larger files.

## HEREDOCS

A [heredoc](https://tldp.org/LDP/abs/html/here-docs.html) is a special type of code block that can be embedded in your script, they take the form

```
[COMMAND] << DELIMITER
your 
text
here
DELIMITER
```

Where `[COMMAND]` is the command you wish to run on your heredoc 'file' and `DELIMITER` is an arbritary string.



> ## Choice of delimiter
> `EOF` (short for end-of-file) is a common choice of delimiter, however this is only a convention. `EOF` has no special properties and any alternative string can be used.
{: .callout}

This can be used as an alterntive to creating a seperate Slurm script.

```
sbatch <<EOF
#!/bin/bash

#SBATCH --job-name test-heredoc
#SBATCH --time 00:01:00
pwd
EOF
```

Or, creating a new file.

```
cat <<EOF > my-new-file.txt
Line One 
Line Two
Line Three
EOF
```

If you recall your bash basics `cat` is used to get the contents of a file, the command `cat my-old-file.txt > my-new-file.txt` copies the contents of the first file to the latter. What we are doing here is the same, except the file being `cat`'d is replaced by the HEREDOC delimiter `cat << EOF > my-new-file.txt`

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

cat << EOF > file.txt
The current working directory is: $PWD
You are logged in as: $(whoami)
EOF

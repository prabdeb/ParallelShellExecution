# Parallel Shell Execution

For executing any Linux Commands in Parallel with proper log management and error handling - A Perl based setup

## How to use

This utility can be placed in any location in a linux box and can be executed from there.

```sh
$ git clone https://github.com/prabdeb/ParallelShellExecution.git
$ cd ParallelShellExecution
$ ./parallel.pl

USAGE: ./parallel.pl -l [Log Directory] -f [File Containing All Commands] -c [Commands Seprated by (,)]

-l : Log Directory where all logs will be dumped, default $(pwd)
-f : File Containing All Commands, separated by new line,
     to provide unique log file name to command, appaned -> commandLogFileName end of each command,
     else it will create the log with command sequence number
-c : Provide all the commands separated by (,) useful in case of few small commands
-m : Maximum Number of Process, which should be executed parallel, default and highest: 5
-t : Specify Timeout in second, example 1800 for 30 Mintues, default: 0 (means no timeout)
```

## Use with Docker

To execute as docker container, follow - 

```sh
$ docker pull prabdeb/parallel
$ docker run prabdeb/parallel -c 'echo "I am command 1",echo "I am command 2"'

20180806 10:54:42 - Starting Parallel Execution of Commands below with Maximum Parallel Process of 5 -
20180806 10:54:42 - echo "I am command 1"
20180806 10:54:42 - echo "I am command 2"
20180806 10:54:42 - =================== START EXECUTION =======================
20180806 10:54:42 - Executing echo "I am command 1"
20180806 10:54:42 - Executing echo "I am command 2"
20180806 10:54:42 - I am command 1
20180806 10:54:42 - I am command 2
20180806 10:54:42 - Successfully executed echo "I am command 1"
20180806 10:54:42 - Successfully executed echo "I am command 2"
20180806 10:54:42 - -
20180806 10:54:42 - -
20180806 10:54:42 - =================== FAILURE SUMMARY =======================
20180806 10:54:42 - =================== EXIT DICISSION ========================
20180806 10:54:42 - Successfully executed All the Commands
```
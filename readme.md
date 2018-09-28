# Bash Script to export a total size of a hash value from Redis

This will allow you to export a total key of a hash value from Redis that is being used as a session provider for a Web Forms application.

*Although with some tweaking it can be used to get a hash value and get it's keys and produce a size value*


## Pre-requisites
This script relies on `redis-cli` being installed and operable.

You can usually do this by using your linux distributions package manager and installing `redis-tools` for example on Ubuntu like distro's that'd be:

```
sudo apt install redis-tools
```

But you get the point.

For more information you can look [here](https://redis.io/topics/rediscli)

## Usage examples

Below is the full help text.
```
Usage: ./exportredisdata.sh {-o|--host <hostname>} {-p|--port <port number>} [-h|\?|--help] [-f|--file|--file= <filename>] <session guid>
    -o|--hostname - pass the url/hostname of the redis server
    -p|--port - pass the port number of the redis server
    -f|--file|--file= <filename> - optionally pass the name of a file and the script will output a file with keys and their lengths
    session guid - this is the session guid that you wish to export data for.
```

The most basic usage is:

```
./exportredisdata.sh --host localhost --port 6379 <a guid>
```

Export every key from hash into a file

```
./exportredisdata.sh --host localhost --port 6379 --file=output.txt <a guid>
```
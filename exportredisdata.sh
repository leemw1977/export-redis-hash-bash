#!/bin/bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
file=
# verbose=0

show_help ()
{
	printf "Usage: $0 {-o|--host <hostname>} {-p|--port <port number>} [-h|\?\--help] [-f|--file|--file= <filename>] <session guid>\n    -o|--hostname - pass the url/hostname of the redis server\n    -p|--port - pass the port number of the redis server\n    -f|--file|--file= <filename> - optionally pass the name of a file and the script will output a file with keys and their lengths\n    session guid - this is the session guid that you wish to export data for."
	die 
}
while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -o|--host)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                connectionHostName=$2
                shift
            else
                die 'ERROR: "--host" requires a non-empty option argument.'
            fi
            ;;
        --host=?*)
            host=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --host=)         # Handle the case of an empty --file=
            die 'ERROR: "--host" requires a non-empty option argument.'
            ;;
        -p|--port)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                connectionHostPort=$2
                shift
            else
                die 'ERROR: "--host" requires a non-empty option argument.'
            fi
            ;;
		-f|--file)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                file=$2
                shift
            else
                die 'ERROR: "--file" requires a non-empty option argument.'
            fi
            ;;
        --file=?*)
            file=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --file=)         # Handle the case of an empty --file=
            die 'ERROR: "--file" requires a non-empty option argument.'
            ;;
		# -v|--verbose)
        #     verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
        #     ;;
        # --)              # End of all options.
        #     shift
        #     break
        #     ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so check we have non-optional parameters and break out of the loop.
			[[ -z "$connectionHostName" ]] && show_help;
			[[ -z "$connectionHostPort" ]] && show_help;
            break
    esac

    shift
done


# Rest of the program here.
# If there are input files (for example) that follow the options, they
# will remain in the "$@" positional parameters.

sessionGuid=$1


echo "Host name: $connectionHostName"
echo "Host port:$connectionHostPort"
echo "Session Guid: $sessionGuid"

#connectionHostName=ukp-sredis.tcb.systems
#connectionHostPort=6379

totalSize=0
while IFS= read -r line; do	
	value=$(echo HSTRLEN {/_$sessionGuid}_Data "$line" | redis-cli -h $connectionHostName -p $connectionHostPort -c | sed '/Redirected/d')
	((totalSize+=value))
	[[ -z "$file" ]] && break || printf "$line: $value\n" >> $file
done < <(echo "$(echo HKEYS {/_$sessionGuid}_Data | redis-cli -h $connectionHostName -p $connectionHostPort -c | sed '/Redirected/d')")

echo "Total Size: $totalSize"


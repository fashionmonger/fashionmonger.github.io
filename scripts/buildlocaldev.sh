#!/bin/bash

### ------------------------ ###
# buildlocaldev.sh
# Author: [Chris Bishop (aka @chris-bishop)](https://github.com/chris-bishop) 
# Date: 18Jul2021
# Purpose: Automated build script for use in local development of Jekyll static
#           web bundles intended for deployment to Git Pages
### ------------------------ ###

### --- SET ARG DEFAULTS --- ###
SCRIPTNAME="$0"
CLEANBUILD=0;
SERVEBUILD=0;
BUILDCONTEXT="";
### --- EVALUATE CMD LINE ARGS --- ###

# -- print usage when arg parsing has errors or user asked for help -- #
usage () {
    printf "Usage: $0 <options> <parameters>

            Options:
                    [ -c | --clean ]    ## -- Clean build context of previous build artifacts - DEFAULT: FALSE -- ##
                    [ -s | --serve ]    ## -- Start Jekyll Server and rebuild on source changes - DEFAULT: FALSE -- ##
                    [ -h | --help  ]    ## -- Help - Print the proper usage info -- ##
            Parameters:
                    [ -p | --path  ]    ## -- Build context path - The directory to use as build context - REQUIRED -- ##

            Examples:

            Execute a clean build and start Jekyll with change polling in the supplied directory:

            $0 -c -s --path /home/$(whoami)/gitpages/myblog

            Execute build without cleaning in the current directory and do not run Jekyll after:

            $0 -p \$(pwd)\n\n";
    exit 2;
}

## -- make sure we were some args -- ##
[[ "$#" -eq "0" ]] && usage;

# -- parse supplied cmdline args and do initial validation using bash getopts util -- #
# -- See: https://www.shellscript.sh/tips/getopt/ -- #
PARSED_ARGUMENTS=$(getopt -a -n ${SCRIPTNAME} -o cshp: --long clean,serve,help,path: -- "$@");
VALID_ARGUMENTS=$?;
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

## -- getopts found valid args so lets try to use them whilst doing our own extra validation -- ##
echo "Supplied arguments: $PARSED_ARGUMENTS";
eval set -- "$PARSED_ARGUMENTS"
while :
do
    case "$1" in
        -c | --clean)   CLEANBUILD=1      ; shift   ;;
        -s | --serve)   SERVEBUILD=1      ; shift   ;;
        -p | --path)    BUILDCONTEXT="$2" ; shift 2 ;;
        -h | --help)    usage             ; shift   ;;
        # -- means the end of the arguments; drop this, and break out of the while loop
        --) shift; break ;;
        # If invalid options were passed, then getopt should have reported an error,
        # which we checked as VALID_ARGUMENTS when getopt was called...
        *)  
            echo "Unrecognized argument: $1";
            echo "Please see proper usage below, or pass --help at any time for more info.";
            usage ;;
    esac
done;
## -- check to see if user supplied us a valid directory as singular arg and --##
## -- confirm we have values for all required args before attempting build -- ##
#[[ "${CLEANBUILD}" -ne "" ]] && [[ "${SERVEBUILD}" -ne "" ]] && 

if [[ "${BUILDCONTEXT}" != "" ]] && [[ -d "${BUILDCONTEXT}" ]] 
then
    echo "Directory exists: ${BUILDCONTEXT}"; 
else
    echo "Directory does not exist: ${BUILDCONTEXT}"; 
    usage;
fi

### --- Validation checks all passed - START BUILD --- ###

echo "[`date`] -- Starting Jekyll Bundle Assembly:";

echo "--------------------------------------------------------------------------------------";

echo "CLEANBUILD      : ${CLEANBUILD}";
echo "SERVEBUILD      : ${SERVEBUILD}";
echo "BUILDCONTEXT    : ${BUILDCONTEXT}";

echo "--------------------------------------------------------------------------------------";

echo "[`date`] -- Kill any zombie Jekyll Dev Server threads:";

echo "--------------------------------------------------------------------------------------";

echo "pkill -f jekyll";

pkill -f jekyll;

echo "--------------------------------------------------------------------------------------";

echo "[`date`] -- Change workspace to Build Context:";

echo "--------------------------------------------------------------------------------------";

echo "cd ${BUILDCONTEXT}";

cd ${BUILDCONTEXT};

echo "--------------------------------------------------------------------------------------";

echo "[`date`] -- Install and Update Dependencies:";

echo "--------------------------------------------------------------------------------------";

echo "bundle install";

bundle install;

echo "bundle update";

bundle update;

echo "--------------------------------------------------------------------------------------";

# echo "[`date`] -- Clean Build Context Before Fresh Build:";

# echo "--------------------------------------------------------------------------------------";

# echo "bundle exec jekyll clean";

# bundle exec jekyll clean;

# echo "--------------------------------------------------------------------------------------";

echo "[`date`] -- Bundle Fresh Build:";

echo "--------------------------------------------------------------------------------------";

echo "bundle exec jekyll build";

bundle exec jekyll build;

echo "--------------------------------------------------------------------------------------";

echo "[`date`] -- Spin up Jekyll Dev Server on Fresh Build:";

echo "--------------------------------------------------------------------------------------";

echo "bundle exec jekyll serve --detach";

bundle exec jekyll serve --detach;

if [ "$?" -eq "0" ];
then
    echo "--------------------------------------------------------------------------------------";
    echo "[`date`] -- Bundle and Jekyll Server Spinup - SUCCESSFUL";
    echo "[`date`] -- Open Browser - Nav to http://localhost:4000/ to view the running new build";
    exit 0;
else
    echo "--------------------------------------------------------------------------------------";
    echo "[`date`] -- Bundle and Jekyll Server Spinup - FAILED";
    echo "[`date`] -- EXITED WITH CODE($?)";
    exit 1;
fi
#!/bin/bash

# fail on any error
set -o errexit

# always run from project root
script_path=`dirname $0`
cd $script_path/..

# run actual command
vendor/neam/dna-project-base-cloud-deployment/util/docker-cloud-shell.sh $@

exit 0

#!/bin/bash

# Script to prepare a new cloud database

# The following env vars needs to be set properly:
# - APPVHOST
# - DEV_RDS_HOST
# - DEMO_RDS_HOST
# - PROD_RDS_HOST

# debug

#set -x

# fail on any error
set -o errexit

# Show script name and line number when errors occur to make buildpack errors easier to debug
trap 'echo "Script error in $0 on or near line ${LINENO}"' ERR

function dbusername {

    local STR=$1

    # Hash to avoid username collisions
    STR=$(printf "%s" "$STR" | md5sum)
    # Max length 16 chars
    STR=${STR:0:16}

    echo "$STR"

}

function dbname {

    local STR=$1

    # Permitted characters in unquoted identifiers: [0-9,a-z,A-Z$_] (basic Latin letters, digits 0-9, dollar, underscore)
    STR=${STR//\//_}
    STR=${STR//./_}
    STR=${STR//-/_}
    STR="$(echo $STR | tr '[:upper:]' '[:lower:]')" # UPPERCASE to lowercase
    # Max length 64 chars
    STR=${STR:0:64}

    echo "$STR"

}

function newdbpass {

    local STR=""
    STR=$(< /dev/urandom LC_CTYPE=C LC_ALL=C tr -dc A-Za-z0-9 | head -c 16)
    echo "$STR"

}

# Set database provider details
if [[ "$APPVHOST" == *.local ]]; then
    #docker-md-plugin
    export DATABASE_HOST='$LOCAL_MOCK_DATABASE_HOST'
    export DATABASE_PORT='$LOCAL_MOCK_DATABASE_PORT'
else
    if [ "$GRANULARITY" == "project-branch-commit-specific" ] || ([[ "$DRONE_BRANCH" != release* ]] && [[ "$DRONE_BRANCH" != hotfix* ]] && [ "$DRONE_BRANCH" != "master" ]); then
        #amazon-rds
        export DATABASE_HOST=$DEV_RDS_HOST
        export DATABASE_PORT=3306
    else
        # Use demo rds for demo deployments, otherwise use production rds
        if [[ "$DRONE_BRANCH" == demo* ]]; then
          #amazon-rds
          export DATABASE_HOST=$DEMO_RDS_HOST
          export DATABASE_PORT=3306
        else
          #amazon-rds
          export DATABASE_HOST=$PROD_RDS_HOST
          export DATABASE_PORT=3306
        fi
    fi
fi

export NEW_DATABASE_USER=$(dbusername $APPVHOST)
export NEW_DATABASE_NAME=$(dbname $APPVHOST)
export NEW_DATABASE_PASSWORD=$(newdbpass)

if [[ "$APPVHOST" == *.local ]]; then
    echo 'Adding the following to .'"$DATA"'.env:'
    echo
    echo 'DATABASE_HOST="'$DATABASE_HOST'"' | tee .$DATA.env
    echo 'DATABASE_PORT="'$DATABASE_PORT'"' | tee -a .$DATA.env
    echo 'DATABASE_USER="'$NEW_DATABASE_USER'"' | tee -a .$DATA.env
    echo 'DATABASE_NAME="'$NEW_DATABASE_NAME'"' | tee -a .$DATA.env
    echo 'DATABASE_PASSWORD="'$NEW_DATABASE_PASSWORD'"' | tee -a .$DATA.env
else
    echo 'Obtain the access details from a team mate, or if this is a new deployment, add the following to deploy/config/secrets.php:'
    echo
    echo '    case "'$APPVHOST'":'
    echo '        $_ENV["DATABASE_HOST"] = "'$DATABASE_HOST'";'
    echo '        $_ENV["DATABASE_PORT"] = "'$DATABASE_PORT'";'
    echo '        $_ENV["DATABASE_USER"] = "'$NEW_DATABASE_USER'";'
    echo '        $_ENV["DATABASE_NAME"] = "'$NEW_DATABASE_NAME'";'
    echo '        $_ENV["DATABASE_PASSWORD"] = "'$NEW_DATABASE_PASSWORD'";'
    echo '        break;'
fi
echo
echo 'Then run the following to create the cloud database with these credentials:'
echo
echo "    vendor/neam/yii-dna-deployment/util/setup-db.sh $DATABASE_HOST $DATABASE_PORT $NEW_DATABASE_NAME $NEW_DATABASE_USER $NEW_DATABASE_PASSWORD"
echo

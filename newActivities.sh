#!/usr/bin/env bash
function reFormatNum() {
    argLength=${#1}
    
    if [[ argLength -eq 1 ]]; then
        echo "0${1}"
    else
        echo $1
    fi
}

# Display help messages if help flag passed
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "[Week Number]         week number for the desired new activities in the source repo"
    echo "[Start Activity]      starting activity to copy"
    echo "[End Activity]        ending activity to copy (inclusive)"
    echo "options:"
    echo "-h, --help            show brief help"
    echo "-c, --commit          commit the changes but do not push"
    echo "-p, --push            push new activities to dest origin"
    exit 0
fi

SHOULD_COMMIT=0
SHOULD_PUSH=0

# set SHOULD_COMMIT to 1 if commit flag passed
if [[ $1 == "-c" ]] || [[ $1 == "--commit" ]]; then
    SHOULD_COMMIT=1
    # pop the flag from the arguments list
    shift
fi

# set SHOULD_PUSH and SHOULD_COMMIT to 1 if push flag passed
if [[ $1 == "-p" ]] || [[ $1 == "--push" ]]; then
    SHOULD_PUSH=1
    SHOULD_COMMIT=1
    # pop the flag from the arguments list
    shift
fi

if [[ "$#" -ne 3 ]]; then
    echo "Usage: ./newActivities.sh [options] [Week Number] [Start Activity] [End Activity]. Type -h or --help for more information."
else
    # load path vars $pathtoContent and $pathToStudentRepo
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source "${DIR}/.env"
    
    # clean and pull latest content from source
    cd $pathToContent
    printf 'Cleaning source repository...\n'
    git checkout -q .
    git clean -fdq
    printf '\nPulling latest changes...\n'
    git pull
    
    cd $pathToStudentRepo
    
    weekNum=$(reFormatNum $1)
    
    if [ ! -d $(echo ${pathToStudentRepo}/${weekNum}*) ] ; then
        printf "\nFatal: $pathToStudentRepo doesn't have a week $weekNum directory.\n"
        printf "Please use the newWeek script to create a folder for that week.\n"
        exit
    fi
    
    weekDirName=$(echo ${pathToContent}/01*/${weekNum}* | sed -E 's/^[^0-9].*Content\/([0-9]+.*)/\1/')
    
    if [ ! -d $(echo ${pathToStudentRepo}/${weekNum}*/01-Activities) ] ; then
        printf "\n$(echo ${pathToStudentRepo}/${weekNum}*)/01-Activities isn't a directory.\n"
        
        read -p "Would you like to make it? " yn
        case $yn in
            "Yes"|"Y"|"yes"|"y" ) mkdir ${pathToStudentRepo}/${weekDirName}/01-Activities; ;;
            * ) printf "Exiting script...\n" && exit;;
        esac
    fi
    
    for num in $(seq $2 $3); do
        activityNum=$(reFormatNum $num)
        
        rsync -av --progress ${pathToContent}/01*/${weekNum}*/01*/${activityNum}* ${pathToStudentRepo}/${weekNum}*/01* --exclude Solved > /dev/null
        
        # add activity to source control
        if [[ $SHOULD_COMMIT -eq 1 ]] ; then
            git add ${weekNum}*/01*/${activityNum}*
        fi
        
        activity=$(echo ${pathToContent}/01*/${weekNum}*/01*/${activityNum}* | sed -E 's/^[^0-9].*Activities\/([0-9]+.*)/\1/')
        destination=$(echo ${pathToStudentRepo}/${weekNum}*/01* | sed -E 's/^.*(UCD.*)/\1/')
        
        barLength=$((${#activity} + ${#destination} + 4))
        
        printf '\n'
        printf '%.0s-' $(seq 1 $barLength)
        printf '\n'
        printf "$activity -> $destination"
        printf '\n'
        printf '%.0s-' $(seq 1 $barLength)
        printf '\n'
    done
    
    # commit if SHOULD_COMMIT
    if [[ $SHOULD_COMMIT -eq 1 ]]; then
        git commit -m "activities $2-$3"
    fi
    
    #  push if SHOULD_PUSH
    if [[ $SHOULD_PUSH -eq 1 ]] ; then
        git push
    fi
fi

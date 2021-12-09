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
    echo "[Week Number]         week number for the desired activity solutions in the source repo"
    echo "[Start Activity]      starting activity to copy"
    echo "[End Activity]        ending activity to copy (inclusive)"
    echo "options:"
    echo "-h, --help            show brief help"
    echo "-c, --commit          commit the changes but do not push"
    echo "-p, --push            push activity solutions to dest origin"
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
    echo "Usage: ./solutionsToActivities.sh [options] [Week Number] [Start Activity] [End Activity]. Type -h or --help for more information."
else
    # load path vars $pathtoContent and $pathToStudentRepo
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source "${DIR}/.env"
    
    cd $pathToStudentRepo
    
    weekNum=$(reFormatNum $1)
    
    for num in $(seq $2 $3); do
        activityNum=$(reFormatNum $num)
        
        if [[ -n "$(ls ${pathToContent}/01*/${weekNum}*/01*/${activityNum}*/Solved 2>/dev/null)" ]]; then
            # undo any changes in activity prior to copy
            git checkout -q ${weekNum}*/01*/${activityNum}*
            cd $pathToContent
            git checkout -q ${pathToContent}/01*/${weekNum}*/01*/${activityNum}*/Solved
            cd $pathToStudentRepo
            
            cp -r ${pathToContent}/01*/${weekNum}*/01*/${activityNum}*/Solved ${pathToStudentRepo}/${weekNum}*/01*/${activityNum}*
            
            # git add activity
            if [[ $SHOULD_COMMIT -eq 1 ]] ; then
                git add ${weekNum}*/01*/${activityNum}*
            fi
            
            source=$(echo ${pathToContent}/01*/${weekNum}*/01*/${activityNum}*/Solved | sed -E 's/.*Activities\/([0-9]+.*)/\1/')
            destination=$(echo ${pathToStudentRepo}/${weekNum}*/01*/${activityNum}* | sed -E 's/^.*(UCD.*)/\1/')
            
            barLength=$((${#source} + ${#destination} + 4))
            
            printf '%.0s-' $(seq 1 $barLength)
            printf '\n'
            printf "$source -> $destination"
            printf '\n'
            printf '%.0s-' $(seq 1 $barLength)
            printf '\n\n'
        else
            activity=$(echo ${pathToContent}/01*/${weekNum}*/01*/${activityNum}* | sed -E 's/.*Activities\/([0-9]+.*)/\1/')
            tail="/Solved Not Found"
            barLength=$((${#activity} + ${#tail}))
            
            printf '%.0s-' $(seq 1 $barLength)
            printf '\n'
            echo "${activity}${tail}"
            printf '%.0s-' $(seq 1 $barLength)
            printf '\n\n'
        fi
    done
    
    # commit if SHOULD_COMMIT
    if [[ $SHOULD_COMMIT -eq 1 ]]; then
        git commit -m "activity $2-$3 solutions"
    fi
    
    #  push if SHOULD_PUSH
    if [[ $SHOULD_PUSH -eq 1 ]] ; then
        git push
    fi
fi
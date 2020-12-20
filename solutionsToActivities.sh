#!/usr/bin/env bash
function reFormatNum() {
  argLength=${#1}

  if [[ argLength -eq 1 ]]; then
    echo "0${1}"
  else
    echo $1
  fi
}

if [[ "$#" -ne 3 ]]; then
  echo "Usage: ./solutionsToActivities.sh [Week Number] [Start Activity] [End Activity]"
else
  # load path vars $pathtoContent and $pathToStudentRepo
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source "${DIR}/.env"

  weekNum=$(reFormatNum $1)

  for num in $(seq $2 $3); do
    activityNum=$(reFormatNum $num)

    if [[ -n "$(ls ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved 2>/dev/null)" ]]; then
      cp -r ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved ${pathToStudentRepo}/${weekNum}*/01*/${activityNum}*
      pathToSolved=$(cd ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved; pwd)

      source=$(echo ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved | sed -E 's/.*Activities\/([0-9]+.*)/\1/')
      destination=$(echo ${pathToStudentRepo}/${weekNum}*/01*/${activityNum}* | sed -E 's/^.*(UCD.*)/\1/')

      barLength=$((${#source} + ${#destination} + 4))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      printf "$source -> $destination"
      printf '\n'
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    else
      activity=$(echo ${pathToContent}/${weekNum}*/01*/${activityNum}* | sed -E 's/.*Activities\/([0-9]+.*)/\1/')
      tail="/Solved Not Found"
      barLength=$((${#activity} + ${#tail}))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      echo "${activity}${tail}"
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    fi 
  done
fi
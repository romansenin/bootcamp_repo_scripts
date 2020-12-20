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
  echo "Usage: ./newWeek.sh [Week Number] [Start Activity] [End Activity]"
else
  # load path vars $pathtoContent and $pathToStudentRepo
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source "${DIR}/.env"

  weekNum=$(reFormatNum $1)

  newWeekDirName=$(echo ${pathToContent}/01*/${weekNum}* | sed -E 's/^[^0-9].*Content\/([0-9]+.*)/\1/')

  mkdir ${pathToStudentRepo}/${newWeekDirName}
  mkdir ${pathToStudentRepo}/${newWeekDirName}/01-Activities

  for num in $(seq $2 $3); do
    activityNum=$(reFormatNum $num)

    rsync -av --progress ${pathToContent}/01*/${weekNum}*/01*/${activityNum}* ${pathToStudentRepo}/${weekNum}*/01* --exclude Solved > /dev/null

    activity=$(echo ${pathToContent}/01*/${weekNum}*/01*/${activityNum}* | sed -E 's/^[^0-9].*Activities\/([0-9]+.*)/\1/')
    destination=$(echo ${pathToStudentRepo}/${weekNum}*/01* | sed -E 's/^.*(UCD.*)/\1/')

    barLength=$((${#activity} + ${#destination} + 4))

    printf '%.0s-' $(seq 1 $barLength)
    printf '\n'
    printf "$activity -> $destination"
    printf '\n'
    printf '%.0s-' $(seq 1 $barLength)
    printf '\n\n'
  done

  rsync -av --progress ${pathToContent}/01*/${weekNum}* ${pathToStudentRepo} --exclude 01-Activities --exclude Solved --exclude Main > /dev/null
fi
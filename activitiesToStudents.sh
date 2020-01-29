function reFormatNum() {
  argLength=${#1}

  if [[ argLength -eq 1 ]]; then
    echo "0${1}"
  else
    echo $1
  fi
}

if [[ "$#" -ne 3 ]]; then
  echo "Usage: ./activitiesToStudents.sh [Week Number] [Start Activity] [End Activity]"
else
  pathToContent="/Users/rasenin/Desktop/ucd-boot-camp/gitlab/December/fullstack-ground/01-Class-Content"
  pathToStudentRepo="/Users/rasenin/Desktop/ucd-boot-camp/gitlab/December/UCD-SAC-FSF-PT-12-2019-U-C"

  weekNum=$(reFormatNum $1)

  for num in $(seq $2 $3); do
    activityNum=$(reFormatNum $num)

    rsync -av --progress ${pathToContent}/${weekNum}*/01*/${activityNum}* ${pathToStudentRepo}/${weekNum}*/01* --exclude Solved > /dev/null

    activity=$(echo ${pathToContent}/${weekNum}*/01*/${activityNum}* | sed -E 's/^[^0-9].*Activities\/([0-9]+.*)/\1/')
    destination=$(echo ${pathToStudentRepo}/${weekNum}*/01* | sed -E 's/^.*(UCD.*)/\1/')

    barLength=$((${#activity} + ${#destination} + 4))

    printf '%.0s-' $(seq 1 $barLength)
    printf '\n'
    printf "$activity -> $destination"
    printf '\n'
    printf '%.0s-' $(seq 1 $barLength)
    printf '\n\n'
  done
fi